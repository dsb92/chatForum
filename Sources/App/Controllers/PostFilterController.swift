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
        
        return Post.query(on: request).all().flatMap(to: PostsResponse.self) { posts in
            var match = [Post]()
            posts.forEach { post in
                if let geolocation = post.geolocation, let country = geolocation.country, country == queryCountry {
                    match.append(post)
                }
            }
            return Future.map(on: request) { return PostsResponse(posts: match) }
        }
    }
}
