import Vapor
import Fluent

struct CommentsResponse: Codable {
    var comments: [Comment]
}

extension CommentsResponse: Content { }

final class CommentController: RouteCollection {
    // Register all 'users' routes
    func boot(router: Router) throws {
        let comments = router.grouped("comments")
        
        // Regiser each handler
        comments.get(use: getComments)
        comments.post(Comment.self, use: postComment)
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
        return comments.create(on: request)
    }
}
