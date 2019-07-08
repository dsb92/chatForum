import Vapor
import Fluent

struct CommentsResponse: Codable {
    var comments: [Comment]
}

extension CommentsResponse: Content { }

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
        comments.post(Comment.self, use: postComment)
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
    func postLike(_ request: Request)throws -> Future<Comment.Likes> {
        return try request.parameters.next(Comment.self).flatMap { comment in
            self.likesManager.like(numberOfLikes: &comment.numberOfLikes)
            return self.updateLikes(request, comment: comment)
        }
    }
    
    func deleteLike(_ request: Request)throws -> Future<Comment.Likes> {
        return try request.parameters.next(Comment.self).flatMap { comment in
            self.likesManager.deleteLike(numberOfLikes: &comment.numberOfLikes)
            return self.updateLikes(request, comment: comment)
        }
    }
    
    // DISLIKES
    func postDislike(_ request: Request)throws -> Future<Comment.Dislikes> {
        return try request.parameters.next(Comment.self).flatMap { comment in
            self.likesManager.dislike(numberOfDislikes: &comment.numberOfDislikes)
            return self.updateDislikes(request, comment: comment)
        }
    }
    
    func deleteDislike(_ request: Request)throws -> Future<Comment.Dislikes> {
        return try request.parameters.next(Comment.self).flatMap { comment in
            self.likesManager.deleteDislike(numberOfDislikes: &comment.numberOfDislikes)
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
    func postComment(_ request: Request, _ comment: Comment)throws -> Future<Comment> {
        let _ = Post.find(comment.postID, on: request).flatMap(to: Post.self) { post in
            guard let post = post, let postID = post.id else { throw Abort.init(HTTPStatus.notFound) }
            self.commentsManager.comment(numberOfComments: &post.numberOfComments)
            return post.update(on: request).flatMap() { updatedPost in
                // Check if comment is on parent comment
                if comment.parentID == nil {
                    // Check if comment is created by owner of Post. We don't want to send push to ourselves :)
                    if let pushTokenID = updatedPost.pushTokenID, pushTokenID != comment.pushTokenID {
                        self.sendPush(on: request, eventID: postID, title: "You've a new comment on your post", body: comment.comment)
                    }
                }
                return Future.map(on: request) { return updatedPost }
            }
        }
        
        if let parentID = comment.parentID {
            let _ = Comment.find(parentID, on: request).flatMap(to: Comment.self) { parentComment in
                guard let parentComment = parentComment else { throw Abort.init(HTTPStatus.notFound) }
                self.commentsManager.comment(numberOfComments: &parentComment.numberOfComments)
                return parentComment.update(on: request).flatMap { updatedComment in
                    if let pushTokenID = updatedComment.pushTokenID, pushTokenID != comment.pushTokenID {
                        self.sendPush(on: request, eventID: parentID, title: "You've a new comment on your comment", body: comment.comment)
                    }
                    return Future.map(on: request) { return updatedComment }
                }
            }
        }
        
        return comment.create(on: request).flatMap { newComment in
            if let commentID = newComment.id, let pushTokenID = newComment.pushTokenID {
                let event = NotificationEvent(pushTokenID: pushTokenID, eventID: commentID)
                let _ = NotificationEvent.query(on: request).create(event)
            }
            
            return Future.map(on: request) { return newComment }
        }
    }
    
    private func updateLikes(_ request: Request, comment: Comment) -> Future<Comment.Likes> {
        return comment.update(on: request).map { comment in
            return Comment.Likes(
                numberOfLikes: comment.numberOfLikes ?? 0
            )
        }
    }
    
    private func updateDislikes(_ request: Request, comment: Comment) -> Future<Comment.Dislikes> {
        return comment.update(on: request).map { post in
            return Comment.Dislikes(
                numberOfDislikes: comment.numberOfDislikes ?? 0
            )
        }
    }
    
    private func sendPush(on request: Request, eventID: UUID, title: String, body: String) {
        // Send push to any subscribers
        let fetchedEvent = NotificationEvent
            .query(on: request)
            .filter(\.eventID, .equal, eventID)
            .first()
        let _ = fetchedEvent.flatMap { fetched -> EventLoopFuture<NotificationEvent?> in
            if let fetched = fetched {
                let _ = fetched.subscriber.get(on: request).flatMap { pushToken -> EventLoopFuture<PushToken> in
                    let _ = try self.pushProvider.sendPush(on: request, notification: Notification(token: pushToken.token, title: title, body: body))
                    return Future.map(on: request) { return pushToken }
                }
            }
            return Future.map(on: request) { return fetched }
        }
    }
}
