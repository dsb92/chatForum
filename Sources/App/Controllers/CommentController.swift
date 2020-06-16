import Vapor
import Fluent

final class CommentController: RouteCollection, LikesManagable, CommentsManagable, PushManageable {
    var pushProvider: PushProvider!
    
    var commentsManager: CommentsManager!
    var likesManager: LikesManager!
    
    func boot(router: Router) throws {
        likesManager = LikesManager()
        commentsManager = CommentsManager()
        pushProvider = FCMProvider()
        
        let comments = router.grouped("comments")
        
        comments.get(Comment.parameter, "children", use: getChildren)
        comments.get(use: getComments)
        comments.get(Comment.parameter, use: getComment)
        comments.delete(Comment.parameter, use: deleteComment)
        comments.post(CommentDTO.self, use: postComment)
        comments.post(Comment.parameter, "like", use: postLike)
        comments.delete(Comment.parameter, "like", use: deleteLike)
        comments.post(Comment.parameter, "dislike", use: postDislike)
        comments.delete(Comment.parameter, "dislike", use: deleteDislike)
    }
    
    func getChildren(_ request: Request)throws -> Future<CommentsResponse> {
        return try request.parameters.next(Comment.self).flatMap(to: CommentsResponse.self) { comment in
            let all = try comment.comments?.query(on: request).all()
            
            guard let val = all else {
                let empty = CommentsResponse(comments: [])
                return Future.map(on: request) { return empty }
            }
            
            return val.flatMap { comments in
                let all = CommentsResponse(comments: comments.sorted(by: { (l, r) -> Bool in
                    return l < r
                }))
                return Future.map(on: request) { return all }
            }
        }
    }
    
    // LIKES
    func postLike(_ request: Request)throws -> Future<LikesResponse> {
        let appHeaders = try request.getAppHeaders()
        
        return try request.parameters.next(Comment.self).flatMap { comment in
            self.likesManager.like(numberOfLikes: &comment.numberOfLikes)
            self.sendPush(on: request, pushMessage: comment, pushType: PushType.newLikeOrDislkeOnComment, likesManager: self.likesManager)
            
            if var likedBy = comment.likedBy {
                likedBy.append(appHeaders.deviceID)
                comment.likedBy = likedBy
            } else {
                comment.likedBy = [appHeaders.deviceID]
            }
            
            return self.updateLikes(request, comment: comment)
        }
    }
    
    func deleteLike(_ request: Request)throws -> Future<LikesResponse> {
        let deviceID = try request.getAppHeaders().deviceID
        
        return try request.parameters.next(Comment.self).flatMap { comment in
            self.likesManager.deleteLike(numberOfLikes: &comment.numberOfLikes)
            if let likedBy = comment.likedBy {
                comment.likedBy = likedBy.filter { $0 != deviceID }
            } else {
                comment.likedBy = []
            }
            return self.updateLikes(request, comment: comment)
        }
    }
    
    // DISLIKES
    func postDislike(_ request: Request)throws -> Future<DislikesResponse> {
        let appHeaders = try request.getAppHeaders()
        
        return try request.parameters.next(Comment.self).flatMap { comment in
            self.likesManager.dislike(numberOfDislikes: &comment.numberOfDislikes)
            self.sendPush(on: request, pushMessage: comment, pushType: PushType.newLikeOrDislkeOnComment, likesManager: self.likesManager)
            
            if var dislikedBy = comment.dislikedBy {
                dislikedBy.append(appHeaders.deviceID)
                comment.dislikedBy = dislikedBy
            } else {
                comment.dislikedBy = [appHeaders.deviceID]
            }
            
            return self.updateDislikes(request, comment: comment)
        }
    }
    
    func deleteDislike(_ request: Request)throws -> Future<DislikesResponse> {
        let deviceID = try request.getAppHeaders().deviceID
        
        return try request.parameters.next(Comment.self).flatMap { comment in
            self.likesManager.deleteDislike(numberOfDislikes: &comment.numberOfDislikes)
            if let dislikedBy = comment.dislikedBy {
                comment.dislikedBy = dislikedBy.filter { $0 != deviceID }
            } else {
                comment.dislikedBy = []
            }
            return self.updateDislikes(request, comment: comment)
        }
    }
    
    // GET COMMENT
    func getComment(_ request: Request)throws -> Future<Comment> {
        return try request.parameters.next(Comment.self)
    }
    
    // GET COMMENTS
    func getComments(_ request: Request)throws -> Future<CommentsResponse> {
        let val = Comment.query(on: request).all()
        
        return val.flatMap { comments in
            let all = CommentsResponse(comments: comments.sorted(by: { (l, r) -> Bool in
                return l < r
            }))
            return Future.map(on: request) { return all }
        }
    }
    
    // POST COMMENT
    func postComment(_ request: Request, _ dto: CommentDTO)throws -> Future<Comment> {
        let appHeaders = try request.getAppHeaders()
        
        let comment = Comment(deviceID: appHeaders.deviceID,
                              postID: dto.postID,
                              parentID: nil,
                              comment: dto.comment,
                              updatedAt: dto.updatedAt,
                              likedBy: nil,
                              dislikedBy: nil,
                              numberOfLikes: nil,
                              numberOfDislikes: nil,
                              numberOfComments: nil,
                              pushTokenID: nil)
        
        let _ = comment.post.get(on: request).flatMap(to: Post.self) { post in
            guard let postID = post.id else { throw Abort.init(HTTPStatus.notFound) }
            self.commentsManager.addComment(numberOfComments: &post.numberOfComments)
            return post.update(on: request).flatMap() { updatedPost in
                let _ = Device.get(on: request, deviceID: updatedPost.deviceID).flatMap(to: Device.self) { device in
                    guard let device = device else {
                        throw Abort(.notFound, reason: "deviceID \(updatedPost.deviceID) not found")
                    }
                    // Check if comment is created by owner of Post. We don't want to send push to ourselves :)
                    if device.deviceID != appHeaders.deviceID {
                        self.sendPush(on: request, eventID: postID, title: LocalizationManager.newCommentOnPost, body: comment.comment, category: PushType.newCommentOnPost.rawValue)
                    }
                    return Future.map(on: request) { return device }
                }
                return Future.map(on: request) { return updatedPost }
            }
        }
        
        return comment.create(on: request).flatMap { newComment in
            if let commentID = newComment.id, let pushTokenID = newComment.pushTokenID {
                NotificationEvent.create(on: request, pushTokenID: pushTokenID, eventID: commentID)
            }
            
            let _ = Post.query(on: request)
                .join(\PostFilter.postID, to: \Post.id)
                .filter(\PostFilter.deviceID == appHeaders.deviceID)
                .filter(\PostFilter.postID == newComment.postID)
                .filter(\PostFilter.type == .myComments)
                .first()
                .map { first in
                    if first == nil {
                        PostFilter.create(on: request, postID: newComment.postID, deviceID: appHeaders.deviceID, type: .myComments)
                    }
            }
            
            return Future.map(on: request) { return newComment }
        }
    }
    
    // DELETE COMMENT
    func deleteComment(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(Comment.self).delete(on: request).flatMap(to: HTTPStatus.self) { comment in
            if let commentID = comment.id {
                // Delete associated notification events
                let _ = NotificationEvent.query(on: request).filter(\NotificationEvent.eventID, .equal, commentID).delete()
            }
            return comment.post.get(on: request).flatMap(to: HTTPStatus.self) { post in
                self.commentsManager.deleteComment(numberOfComments: &post.numberOfComments)
                return post.update(on: request).transform(to: HTTPStatus.noContent)
            }
        }
    }
    
    private func updateLikes(_ request: Request, comment: Comment) -> Future<LikesResponse> {
        return comment.update(on: request).map { comment in
            return LikesResponse(
                numberOfLikes: comment.numberOfLikes ?? 0
            )
        }
    }
    
    private func updateDislikes(_ request: Request, comment: Comment) -> Future<DislikesResponse> {
        return comment.update(on: request).map { post in
            return DislikesResponse(
                numberOfDislikes: comment.numberOfDislikes ?? 0
            )
        }
    }
}
