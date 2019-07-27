import Vapor
import Fluent

final class PostController: RouteCollection, LikesManagable, PushManageable, LocationManagable {
    var pushProvider: PushProvider!
    var likesManager: LikesManager!
    var locationProvider: LocationProvider!
    
    func boot(router: Router) throws {
        likesManager = LikesManager()
        pushProvider = FCMProvider()
        locationProvider = GMProvider()
        
        let posts = router.grouped("posts")
        
        posts.put(Post.self, use: putPost)
        posts.get(Post.parameter, "comments", use: getComments)
        posts.get(use: getPosts)
        posts.get(Post.parameter, use: getPost)
        posts.delete(Post.parameter, use: deletePost)
        posts.post(Post.self, use: postPost)
        posts.post(Post.parameter, "like", use: postLike)
        posts.delete(Post.parameter, "like", use: deleteLike)
        posts.post(Post.parameter, "dislike", use: postDislike)
        posts.delete(Post.parameter, "dislike", use: deleteDislike)
    }
    
    // COMMENTS
    func getComments(_ request: Request)throws -> Future<CommentsResponse> {
        return try request.parameters.next(Post.self).flatMap(to: CommentsResponse.self) { (post) in
            let val = try post.comments.query(on: request).all()
            return val.flatMap { comments in
                let newComments = comments.filter { $0.parentID == nil }
                let all = CommentsResponse(comments: newComments.sorted(by: { (l, r) -> Bool in
                    return l < r
                }))
                return Future.map(on: request) { return all }
            }
        }
    }
    
    // LIKES
    func postLike(_ request: Request)throws -> Future<LikesResponse> {
        return try request.parameters.next(Post.self).flatMap { post in
            self.likesManager.like(numberOfLikes: &post.numberOfLikes)
            self.sendPush(on: request, pushMessage: post, pushType: PushType.newLikeOrDislikeOnPost, likesManager: self.likesManager)
            return self.updateLikes(request, post: post)
        }
    }
    
    func deleteLike(_ request: Request)throws -> Future<LikesResponse> {
        return try request.parameters.next(Post.self).flatMap { post in
            self.likesManager.deleteLike(numberOfLikes: &post.numberOfLikes)
            return self.updateLikes(request, post: post)
        }
    }
    
    // DISLIKES
    func postDislike(_ request: Request)throws -> Future<DislikesResponse> {
        return try request.parameters.next(Post.self).flatMap { post in
            self.likesManager.dislike(numberOfDislikes: &post.numberOfDislikes)
            self.sendPush(on: request, pushMessage: post, pushType: PushType.newLikeOrDislikeOnPost, likesManager: self.likesManager)
            return self.updateDislikes(request, post: post)
        }
    }
    
    func deleteDislike(_ request: Request)throws -> Future<DislikesResponse> {
        return try request.parameters.next(Post.self).flatMap { post in
            self.likesManager.deleteDislike(numberOfDislikes: &post.numberOfDislikes)
            return self.updateDislikes(request, post: post)
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
        return post.create(on: request).flatMap { newPost in
            if let postID = newPost.id, let pushTokenID = newPost.pushTokenID {
                let event = NotificationEvent(pushTokenID: pushTokenID, eventID: postID)
                let _ = NotificationEvent.query(on: request).create(event)
            }
            
            guard let coordinate2D = post.coordinate2D else {
                return Future.map(on: request) { return newPost }
            }
            
            let promisePost: Promise<Post> = request.eventLoop.newPromise()
            
            let _ = try self.locationProvider.getReverseGeocode(on: request, coordinate2D: coordinate2D).flatMap { geolocation -> EventLoopFuture<Post> in
                guard let postID = newPost.id, let geo = geolocation, let country = geo.country else {
                    promisePost.succeed(result: newPost)
                    return Future.map(on: request) { return newPost }
                }
                
                let location = Location(postID: postID, country: country, flagURL: geo.flagURL, city: geo.city)
                let _ = Location.query(on: request).create(location)
                
                newPost.coordinate2D = nil
                newPost.geolocation = geolocation
                let _ = newPost.save(on: request).flatMap { savedPost in
                    return Future.map(on: request) { () -> Post in
                        promisePost.succeed(result: savedPost)
                        return savedPost
                    }
                }
                
                return Future.map(on: request) { return newPost }
            }
            
            return promisePost.futureResult
        }
    }
    
    // UPDATE POST
    func putPost(_ request: Request, post: Post)throws -> Future<Post> {
        return post.update(on: request)
    }
    
    // DELETE POST
    func deletePost(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(Post.self).delete(on: request).transform(to: .noContent)
    }
    
    private func updateLikes(_ request: Request, post: Post) -> Future<LikesResponse> {
        return post.update(on: request).map { post in
            return LikesResponse(
                numberOfLikes: post.numberOfLikes ?? 0
            )
        }
    }
    
    private func updateDislikes(_ request: Request, post: Post) -> Future<DislikesResponse> {
        return post.update(on: request).map { post in
            return DislikesResponse(
                numberOfDislikes: post.numberOfDislikes ?? 0
            )
        }
    }
}
