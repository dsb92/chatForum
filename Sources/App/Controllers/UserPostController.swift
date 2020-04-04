import Vapor
import Fluent
import Pagination

final class UserPostController: RouteCollection {
    
    func boot(router: Router) throws {
        let userPosts = router.grouped("user/posts")
        userPosts.get(use: getUserPosts)
    }
    
    func getUserPosts(_ request: Request)throws -> Future<Paginated<Post>> {
        return try Post.query(on: request).filter(\.deviceID, .equal, request.getUUIDFromHeader()).paginate(for: request)
    }
}
