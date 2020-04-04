import Vapor
import Fluent
import Pagination

final class PostFilterController: RouteCollection {
    struct Geolocation {
        static let countryParam = "country"
    }
    
    func boot(router: Router) throws {
        let filter = router.grouped("posts/filter")
        filter.get("geolocation", use: getPostsGeolocation)
        filter.get("geolocation/v2", use: getPostsGeolocationV2)
    }
    
    func getPostsGeolocation(_ request: Request)throws -> Future<PostsResponse> {
        guard let queryCountry = request.query[String.self, at: Geolocation.countryParam] else {
            throw Abort(.badRequest)
        }
        
        return Post.query(on: request).all().flatMap(to: PostsResponse.self) { posts in
            var match = [Post]()
            let promise: Promise<PostsResponse> = request.eventLoop.newPromise()
            DispatchQueue.global().async {
                posts.forEach { post in
                    if let geolocation = post.geolocation, let country = geolocation.country, country == queryCountry {
                        match.append(post)
                    }
                }
                
                promise.succeed(result: PostsResponse(posts: match))
            }
            
            return promise.futureResult
        }
    }
    
    func getPostsGeolocationV2(_ request: Request)throws -> Future<Paginated<Post>> {
        guard let queryCountry = request.query[String.self, at: Geolocation.countryParam] else {
            throw Abort(.badRequest)
        }
        
        return try Post.query(on: request).paginate(for: request).flatMap(to: Paginated<Post>.self) { posts in
            var match = [Post]()
            let promise: Promise<Paginated<Post>> = request.eventLoop.newPromise()
            DispatchQueue.global().async {
                posts.data.forEach { post in
                    if let geolocation = post.geolocation, let country = geolocation.country, country == queryCountry {
                        match.append(post)
                    }
                }
                
                promise.succeed(result: Paginated(page: posts.page, data: match))
            }
            
            return promise.futureResult
        }
    }
}
