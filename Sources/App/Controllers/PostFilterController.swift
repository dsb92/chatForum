import Vapor
import Fluent
import Pagination
import FluentPostgreSQL

final class PostFilterController: RouteCollection {
    struct GeolocationURLQueryParam {
        static let country = "country"
    }
    
    func boot(router: Router) throws {
        let filter = router.grouped("posts/filter")
        filter.get("geolocation", use: getPostsGeolocation)
        filter.get("geolocation/v2", use: getPostsGeolocationV2)
        filter.get("myPosts", use: getMyPosts)
        filter.post("myPosts", use: postMyPosts)
        filter.get("myLikes", use: getMyLikes)
        filter.post("myLikes", use: postMyLikes)
        filter.get("myDislikes", use: getMyDislikes)
        filter.post("myDislikes", use: postMyDislikes)
        filter.get("myComments", use: getMyComments)
        filter.post("myComments", use: postMyComments)
    }
    
    // GEOLOCATION
    func getPostsGeolocation(_ request: Request)throws -> Future<PostsResponse> {
        guard let queryCountry = request.query[String.self, at: GeolocationURLQueryParam.country] else {
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
        guard let queryCountry = request.query[String.self, at: GeolocationURLQueryParam.country] else {
            throw Abort(.badRequest)
        }
        
        let geoLocation = Geolocation(country: queryCountry, flagURL: nil, city: nil)
        
        return try Post.query(on: request).filter(\Post.geolocation, .contains, geoLocation).paginate(for: request)
    }
    
    // MYPOSTS
    func getMyPosts(_ request: Request)throws -> Future<Paginated<Post>> {
        return try getUserPosts(request, of: .myPost)
    }
    
    func postMyPosts(_ request: Request)throws -> Future<PostFilter> {
        return try postUserPosts(request, of: .myPost)
    }
    
    // MYLIKES
    func getMyLikes(_ request: Request)throws -> Future<Paginated<Post>> {
        return try getUserPosts(request, of: .myLikes)
    }
    
    func postMyLikes(_ request: Request)throws -> Future<PostFilter> {
        return try postUserPosts(request, of: .myLikes)
    }
    
    // MYDISLIKES
    func getMyDislikes(_ request: Request)throws -> Future<Paginated<Post>> {
        return try getUserPosts(request, of: .myDislikes)
    }
    
    func postMyDislikes(_ request: Request)throws -> Future<PostFilter> {
        return try postUserPosts(request, of: .myDislikes)
    }
    
    // MYCOMMENTS
    func getMyComments(_ request: Request)throws -> Future<Paginated<Post>> {
        return try getUserPosts(request, of: .myComments)
    }
    
    func postMyComments(_ request: Request)throws -> Future<PostFilter> {
        return try postUserPosts(request, of: .myComments)
    }
    
    private func getUserPosts(_ request: Request, of type: PostFilterType)throws -> Future<Paginated<Post>> {
        return try Post.query(on: request).join(\PostFilter.postID, to: \Post.id).filter(\PostFilter.deviceID == request.getUUIDFromHeader()).filter(\PostFilter.type == type).paginate(for: request)
    }
    
    private func postUserPosts(_ request: Request, of type: PostFilterType)throws -> Future<PostFilter> {
        return try request.content.decode(PostFilter.self).map(to: PostFilter.self) { postFilter in
            postFilter.type = type
            postFilter.deviceID = try request.getUUIDFromHeader()
            return postFilter
        }.create(on: request)
    }
}
