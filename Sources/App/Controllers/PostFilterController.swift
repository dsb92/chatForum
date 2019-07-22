import Vapor
import Fluent

final class PostFilterController: RouteCollection {
    struct Geolocation {
        static let countryParam = "country"
    }
    
    func boot(router: Router) throws {
        let filter = router.grouped("posts/filter")
        filter.get("geolocation", use: getPostsGeolocation)
    }
    
    func getPostsGeolocation(_ request: Request)throws -> Future<PostsResponse> {
        guard let queryCountry = request.query[String.self, at: Geolocation.countryParam] else {
            throw Abort(.badRequest)
        }
        
        return Location.query(on: request).filter(\Location.country, .equal, queryCountry).all().flatMap { locations in
            var matches = [Post]()
            let promisePosts: Promise<PostsResponse> = request.eventLoop.newPromise()
            DispatchQueue.global().async {
                locations.forEach { location in
                    let _ = Post.find(location.postID, on: request).unwrap(or: Abort.init(HTTPResponseStatus.notFound)).flatMap { post -> EventLoopFuture<Post> in
                        matches.append(post)
                        return Future.map(on: request) { return post }
                    }
                }
                
                promisePosts.succeed(result: PostsResponse(posts: matches))
            }
            
            return Future.map(on: request) { return PostsResponse(posts: matches) }
        }
    }
}
