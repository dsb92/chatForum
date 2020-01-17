import Vapor
import Fluent
import Pagination

final class PostController: RouteCollection, LikesManagable, PushManageable, LocationManagable, BlockManageable {
    var pushProvider: PushProvider!
    var likesManager: LikesManager!
    var locationProvider: LocationProvider!
    var fileRequester: FileRequester!
    
    func boot(router: Router) throws {
        likesManager = LikesManager()
        pushProvider = FCMProvider()
        locationProvider = GMProvider()
        fileRequester = FileRequester()
        
        let posts = router.grouped("posts")
        
        posts.put(Post.self, use: putPost)
        posts.get(Post.parameter, "comments", use: getComments)
        posts.get(use: getPosts)
        posts.get("/v2", use: getPostsV2)
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
        return try request.parameters.next(Post.self).flatMap(to: CommentsResponse.self) { post in
            let val = try Comment.queryBlocked(on: request, deviceID: request.getUUIDFromHeader()).all()
            
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
        return try Post.queryBlocked(on: request, deviceID: request.getUUIDFromHeader()).all().flatMap(to: PostsResponse.self) { posts in
            return self.removingBlocked(blocked: posts, request: request).flatMap { p in
                return Future.map(on: request) {
                    let sorted = p.sorted(by: { (l, r) -> Bool in
                        return l > r
                    })
                    return PostsResponse(posts: sorted)
                }
            }
        }
    }
    
    func getPostsV2(_ request: Request)throws -> Future<Paginated<Post>> {
        return try Post.queryBlocked(on: request, deviceID: request.getUUIDFromHeader()).all().flatMap(to: Paginated<Post>.self) { paginated in
            return try self.removingBlockedPaginated(blocked: paginated, request: request).flatMap { p in
                return Future.map(on: request) {
                    let sorted = p.data.sorted(by: { (l, r) -> Bool in
                        return l > r
                    })
                    return Paginated(page: p.page, data: sorted)
                }
            }
        }
    }
    
    // GET POST
    func getPost(_ request: Request)throws -> Future<Post> {
        return try request.parameters.next(Post.self)
    }
    
    // POST POST
    func postPost(_ request: Request, _ post: Post)throws -> Future<Post> {
        post.deviceID = try request.getUUIDFromHeader()
        
        return post.create(on: request).flatMap { newPost in
            if let postID = newPost.id, let pushTokenID = newPost.pushTokenID {
                NotificationEvent.create(on: request, pushTokenID: pushTokenID, eventID: postID)
            }
            
            guard let _ = post.coordinate2D else {
                return Future.map(on: request) { return newPost }
            }
            
            return try self.getLocationFromPostByCoordinate2D(request: request, post: newPost).flatMap(to: Post.self) { location in
                newPost.coordinate2D = nil
                newPost.geolocation = Geolocation(country: location.country, flagURL: location.flagURL, city: location.city)
                return newPost.save(on: request)
            }
        }
    }
    
    // UPDATE POST
    func putPost(_ request: Request, post: Post)throws -> Future<Post> {
        post.deviceID = try request.getUUIDFromHeader()
        
        return Post.query(on: request).filter(\Post.id, .equal, post.id).first().flatMap(to: Post.self) { fetchedPost in
            guard let existingPost = fetchedPost else {
                throw Abort(.badRequest)
            }
            
            post.numberOfComments = existingPost.numberOfComments
            post.numberOfLikes = existingPost.numberOfLikes
            post.numberOfDislikes = existingPost.numberOfDislikes
            
            return post.update(on: request).flatMap { newPost in
                
                guard let _ = post.coordinate2D else {
                    return Future.map(on: request) { return newPost }
                }
                
                return try self.getLocationFromPostByCoordinate2D(request: request, post: newPost).flatMap(to: Post.self) { location in
                    newPost.coordinate2D = nil
                    newPost.geolocation = Geolocation(country: location.country, flagURL: location.flagURL, city: location.city)
                    return newPost.save(on: request)
                }
            }
        }
    }
    
    // DELETE POST
    func deletePost(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(Post.self).delete(on: request).flatMap(to: HTTPStatus.self) { post in
            // Delete associated notification events
            if let postID = post.id {
                let _ = NotificationEvent.query(on: request).filter(\NotificationEvent.eventID, .equal, postID).delete()
            }
            
            // Delete associated images
            if let imageId = post.imageIds?.first {
                let _ = try self.fileRequester.deleteFile(with: request, ext: .png, path: .images, id: imageId)
            }
            
            // Delete associated comments
            return try post.comments.query(on: request).delete().transform(to: .noContent)
        }
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
