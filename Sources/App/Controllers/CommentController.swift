import Vapor
import Fluent

struct CommentsResponse: Codable {
    var comments: [Comment]
}

extension CommentsResponse: Content { }

final class CommentController: RouteCollection {
    func boot(router: Router) throws {
        let comments = router.grouped("comments")
        
        comments.get(use: getComments)
        comments.post(Comment.self, use: postComment)
        comments.post(Comment.parameter, "like", use: postLike)
        comments.delete(Comment.parameter, "like", use: deleteLike)
        comments.post(Comment.parameter, "dislike", use: postDislike)
        comments.delete(Comment.parameter, "dislike", use: deleteDislike)
    }
    
    // LIKES
    func postLike(_ request: Request)throws -> Future<Comment.Likes> {
        return try request.parameters.next(Comment.self).flatMap { comment in
            if var numberOfLikes = comment.numberOfLikes {
                numberOfLikes += 1
                comment.numberOfLikes = numberOfLikes
            } else {
                comment.numberOfLikes = 1
            }
            
            return comment.update(on: request).map { comment in
                return Comment.Likes(
                    numberOfLikes: comment.numberOfLikes ?? 0
                )
            }
        }
    }
    
    func deleteLike(_ request: Request)throws -> Future<Comment.Likes> {
        return try request.parameters.next(Comment.self).flatMap { comment in
            if var numberOfLikes = comment.numberOfLikes {
                numberOfLikes -= 1
                
                if numberOfLikes < 0 {
                    numberOfLikes = 0
                }
                
                comment.numberOfLikes = numberOfLikes
            } else {
                comment.numberOfLikes = 0
            }
            
            return comment.update(on: request).map { comment in
                return Comment.Likes(
                    numberOfLikes: comment.numberOfLikes ?? 0
                )
            }
        }
    }
    
    // DISLIKES
    func postDislike(_ request: Request)throws -> Future<Comment.Dislikes> {
        return try request.parameters.next(Comment.self).flatMap { comment in
            if var numberOfDislikes = comment.numberOfDislikes {
                numberOfDislikes += 1
                comment.numberOfDislikes = numberOfDislikes
            } else {
                comment.numberOfDislikes = 1
            }
            
            return comment.update(on: request).map { post in
                return Comment.Dislikes(
                    numberOfDislikes: comment.numberOfDislikes ?? 0
                )
            }
        }
    }
    
    func deleteDislike(_ request: Request)throws -> Future<Comment.Dislikes> {
        return try request.parameters.next(Comment.self).flatMap { comment in
            if var numberOfDislikes = comment.numberOfDislikes {
                numberOfDislikes -= 1
                
                if numberOfDislikes < 0 {
                    numberOfDislikes = 0
                }
                
                comment.numberOfDislikes = numberOfDislikes
            } else {
                comment.numberOfDislikes = 0
            }
            
            return comment.update(on: request).map { post in
                return Comment.Dislikes(
                    numberOfDislikes: comment.numberOfDislikes ?? 0
                )
            }
        }
    }
    
    // GET COMMENTS
    func getComments(_ request: Request)throws -> Future<CommentsResponse> {
        let val = Comment.query(on: request).all()
        return val.flatMap { comments in
            let all = CommentsResponse(comments: comments)
            return Future.map(on: request) {return all }
        }
    }
    
    // POST COMMENT
    func postComment(_ request: Request, _ comments: Comment)throws -> Future<Comment> {
        let _ = Post.find(comments.postID, on: request).flatMap(to: Post.self) { post in
            guard let post = post else { throw Abort.init(HTTPStatus.notFound) }
            if var numberOfComments = post.numberOfComments {
                numberOfComments += 1
                post.numberOfComments = numberOfComments
            } else {
                post.numberOfComments = 1
            }
            
            return post.update(on: request)
        }
        
        return comments.create(on: request)
    }
}
