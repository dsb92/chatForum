import Vapor
import Fluent

final class CommentController: RouteCollection {
    // Register all 'users' routes
    func boot(router: Router) throws {
        let comments = router.grouped("comments")
        
        // Regiser each handler
        comments.get(use: getComments)
        comments.post(Comment.self, use: postComment)
    }
    
    // GET COMMENTS
    func getComments(_ request: Request)throws -> Future<[Comment]> {
        return Comment.query(on: request).all()
    }
    
    // POST COMMENT
    func postComment(_ request: Request, _ comments: Comment)throws -> Future<Comment> {
        return comments.create(on: request)
    }
}
