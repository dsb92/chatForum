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
                    let all = CommentsResponse(comments: comments.sorted(by: { (l, r) -> Bool in
                        return l < r
                    }))
                    return Future.map(on: request) { return all }
                }
            }
        }
        posts.get(use: getPosts)
        posts.get(Post.parameter, use: getPost)
        posts.delete(Post.parameter, use: deletePost)
        posts.post(Post.self, use: postPost)
        posts.post(Post.parameter, "like", use: postLike)
        posts.delete(Post.parameter, "like", use: deleteLike)
        posts.post(Post.parameter, "dislike", use: postDislike)
        posts.delete(Post.parameter, "dislike", use: deleteDislike)
    }
    
    // LIKES
    func postLike(_ request: Request)throws -> Future<Post.Likes> {
        return try request.parameters.next(Post.self).flatMap { post in
            if var numberOfLikes = post.numberOfLikes {
                numberOfLikes += 1
                post.numberOfLikes = numberOfLikes
            } else {
                post.numberOfLikes = 1
            }
            
            return post.update(on: request).map { post in
                return Post.Likes(
                    numberOfLikes: post.numberOfLikes ?? 0
                )
            }
        }
    }
    
    func deleteLike(_ request: Request)throws -> Future<Post.Likes> {
        return try request.parameters.next(Post.self).flatMap { post in
            if var numberOfLikes = post.numberOfLikes {
                numberOfLikes -= 1
                
                if numberOfLikes < 0 {
                    numberOfLikes = 0
                }
                
                post.numberOfLikes = numberOfLikes
            } else {
                post.numberOfLikes = 0
            }
            
            return post.update(on: request).map { post in
                return Post.Likes(
                    numberOfLikes: post.numberOfLikes ?? 0
                )
            }
        }
    }
    
    // DISLIKES
    func postDislike(_ request: Request)throws -> Future<Post.Dislikes> {
        return try request.parameters.next(Post.self).flatMap { post in
            if var numberOfDislikes = post.numberOfDislikes {
                numberOfDislikes += 1
                post.numberOfDislikes = numberOfDislikes
            } else {
                post.numberOfDislikes = 1
            }
            
            return post.update(on: request).map { post in
                return Post.Dislikes(
                    numberOfDislikes: post.numberOfDislikes ?? 0
                )
            }
        }
    }
    
    func deleteDislike(_ request: Request)throws -> Future<Post.Dislikes> {
        return try request.parameters.next(Post.self).flatMap { post in
            if var numberOfDislikes = post.numberOfDislikes {
                numberOfDislikes -= 1
                
                if numberOfDislikes < 0 {
                    numberOfDislikes = 0
                }
                
                post.numberOfDislikes = numberOfDislikes
            } else {
                post.numberOfDislikes = 0
            }
            
            return post.update(on: request).map { post in
                return Post.Dislikes(
                    numberOfDislikes: post.numberOfDislikes ?? 0
                )
            }
        }
    }
    
    // GET POSTS
    func getPosts(_ request: Request)throws -> Future<PostsResponse> {
        let val = Post.query(on: request).all()
        return val.flatMap { posts in
            let all = PostsResponse(posts: posts.sorted(by: { (l, r) -> Bool in
                return l > r
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
