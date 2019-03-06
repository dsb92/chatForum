import Vapor
import Fluent

final class PostController: RouteCollection {
    // Register all 'users' routes
    func boot(router: Router) throws {
        let posts = router.grouped("posts")
        
        // Regiser each handler
        posts.post(Post.self, use: postPost)
        posts.put(Post.self, use: putPost)
        posts.get(Post.parameter, "comments") { request -> Future<[Comment]> in
            return try request.parameters.next(Post.self).flatMap(to: [Comment].self) { (post) in
                return try post.comments.query(on: request).all()
            }
        }
        posts.get(use: getPosts)
        posts.get(Post.parameter, use: getPost)
        posts.delete(Post.parameter, use: deletePost)
    }
    
    // GET POSTS
    func getPosts(_ request: Request)throws -> Future<[Post]> {
        return Post.query(on: request).all()
    }
    
    // GET POST
    func getPost(_ request: Request)throws -> Future<Post> {
        return try request.parameters.next(Post.self)
    }
    
    // POST POST
    func postPost(_ request: Request, _ post: Post)throws -> Future<Post> {
        return post.create(on: request)
    }
    
    // UPDATE POST
    func putPost(_ request: Request, post: Post)throws -> Future<Post> {
        return post.update(on: request)
    }
    
    // DELETE POST
    func deletePost(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(Post.self).delete(on: request).transform(to: .noContent)
    }
}
