import Vapor
import Fluent

struct PostsResponse: Codable {
    var posts: [Post]
}

extension PostsResponse: Content { }

final class PostController: RouteCollection {
    func boot(router: Router) throws {
        let posts = router.grouped("posts")
        
        posts.put(Post.self, use: putPost)
        posts.get(Post.parameter, "comments") { request -> Future<CommentsResponse> in
            return try request.parameters.next(Post.self).flatMap(to: CommentsResponse.self) { (post) in
                let val = try post.comments.query(on: request).all()
                return val.flatMap { comments in
                    let all = CommentsResponse(comments: comments)
                    return Future.map(on: request) { return all }
                }
            }
        }
        posts.get(use: getPosts)
        posts.get(Post.parameter, use: getPost)
        posts.delete(Post.parameter, use: deletePost)
        
        posts.get(use: getPosts)
        posts.post(Post.self, use: postPost)
    }
    
    // GET POSTS
    func getPosts(_ request: Request)throws -> Future<PostsResponse> {
        let val = Post.query(on: request).all()
        return val.flatMap { posts in
            let all = PostsResponse(posts: posts.sorted(by: { (l, r) -> Bool in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                let lDate = dateFormatter.date(from:l.updatedAt) ?? Date()
                let rDate = dateFormatter.date(from: r.updatedAt) ?? Date()
                
                return lDate.compare(rDate) == .orderedDescending
            }))
            return Future.map(on: request) { return all }
        }
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
