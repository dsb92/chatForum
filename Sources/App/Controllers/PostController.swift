import Vapor
import Fluent
import Pagination

final class PostController: RouteCollection, LikesManagable, PushManageable, LocationManagable {
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
        
        posts.get(Post.parameter, "comments", use: getComments)
        posts.get(use: getPosts)
        posts.get(Post.parameter, use: getPost)
        posts.delete(Post.parameter, use: deletePost)
        posts.post(PostDTO.self, use: postPost)
        posts.post(Post.parameter, "like", use: postLike)
        posts.delete(Post.parameter, "like", use: deleteLike)
        posts.post(Post.parameter, "dislike", use: postDislike)
        posts.delete(Post.parameter, "dislike", use: deleteDislike)
    }
    
    // COMMENTS
    func getComments(_ request: Request)throws -> Future<Paginated<Comment>> {
        return try request.parameters.next(Post.self).flatMap(to: Paginated<Comment>.self) { post in
            return try post.comments
                .query(on: request)
                .paginate(for: request)
                .flatMap(to: Paginated<Comment>.self) { paginated in
                    var data = paginated.data
                    // Find all comments that are blocked
                    return try Comment
                        .query(on: request)
                        .join(\BlockedDevice.deviceID, to: \Comment.deviceID)
                        .filter(\BlockedDevice.blockedDeviceID == request.getAppHeaders().deviceID)
                        .all()
                        .flatMap { comments in
                            // Filter them out removing those that should not be visible to requester
                            data = data.filter { comments.contains($0) == false }
                            return Future.map(on: request) { Paginated(page: paginated.page, data: data) }
                    }
            }
            .flatMap { paginated in
                let newComments = paginated.data.filter { $0.parentID == nil }
                return Future.map(on: request) { return Paginated(page: paginated.page, data: newComments) }
            }
        }
    }
    
    // LIKES
    func postLike(_ request: Request)throws -> Future<LikesResponse> {
        let appHeaders = try request.getAppHeaders()
        
        return try request.parameters.next(Post.self).flatMap { post in
            self.likesManager.like(numberOfLikes: &post.numberOfLikes)
            self.sendPush(on: request, pushMessage: post, pushType: PushType.newLikeOrDislikeOnPost, likesManager: self.likesManager)
            if var likedBy = post.likedBy {
                likedBy.append(appHeaders.deviceID)
                post.likedBy = likedBy
            } else {
                post.likedBy = [appHeaders.deviceID]
            }
            if let postID = post.id {
                // Create or update my likes filter
                PostFilter.create(on: request, postID: postID, deviceID: appHeaders.deviceID, type: .myLikes)
            }
            return self.updateLikes(request, post: post)
        }
    }
    
    func deleteLike(_ request: Request)throws -> Future<LikesResponse> {
        let appHeaders = try request.getAppHeaders()
        
        return try request.parameters.next(Post.self).flatMap { post in
            self.likesManager.deleteLike(numberOfLikes: &post.numberOfLikes)
            if let likedBy = post.likedBy {
                post.likedBy = likedBy.filter { $0 != appHeaders.deviceID }
            } else {
                post.likedBy = []
            }
            if let postID = post.id {
                PostFilter.deleteLike(on: request, postID: postID, deviceID: appHeaders.deviceID)
            }
            return self.updateLikes(request, post: post)
        }
    }
    
    // DISLIKES
    func postDislike(_ request: Request)throws -> Future<DislikesResponse> {
        let appHeaders = try request.getAppHeaders()
        
        return try request.parameters.next(Post.self).flatMap { post in
            self.likesManager.dislike(numberOfDislikes: &post.numberOfDislikes)
            self.sendPush(on: request, pushMessage: post, pushType: PushType.newLikeOrDislikeOnPost, likesManager: self.likesManager)
            if var dislikedBy = post.dislikedBy {
                dislikedBy.append(appHeaders.deviceID)
                post.dislikedBy = dislikedBy
            } else {
                post.dislikedBy = [appHeaders.deviceID]
            }
            if let postID = post.id {
                // Create or update my dislikes filter
                PostFilter.create(on: request, postID: postID, deviceID: appHeaders.deviceID, type: .myDislikes)
            }
            return self.updateDislikes(request, post: post)
        }
    }
    
    func deleteDislike(_ request: Request)throws -> Future<DislikesResponse> {
        let appHeaders = try request.getAppHeaders()
        
        return try request.parameters.next(Post.self).flatMap { post in
            self.likesManager.deleteDislike(numberOfDislikes: &post.numberOfDislikes)
            if let dislikedBy = post.dislikedBy {
                post.dislikedBy = dislikedBy.filter { $0 != appHeaders.deviceID }
            } else {
                post.dislikedBy = []
            }
            if let postID = post.id {
                PostFilter.deleteDislike(on: request, postID: postID, deviceID: appHeaders.deviceID)
            }
            return self.updateDislikes(request, post: post)
        }
    }
    
    // GET POSTS
    func getPosts(_ request: Request)throws -> Future<Paginated<Post>> {
        return try Post
            .query(on: request)
            .paginate(for: request)
            .flatMap(to: Paginated<Post>.self) { paginated in
                // Find all posts that are blocked
                return try Post
                    .query(on: request)
                    .join(\BlockedDevice.deviceID, to: \Post.deviceID)
                    .filter(\BlockedDevice.blockedDeviceID == request.getAppHeaders().deviceID)
                    .all()
                    .flatMap { posts in
                        // Filter them out removing those that should not be visible to requester
                        let data = paginated.data.filter { posts.contains($0) == false }
                        return Future.map(on: request) { Paginated(page: paginated.page, data: data) }
                }
        }
    }
    
    // GET POST
    func getPost(_ request: Request)throws -> Future<Post> {
        return try request.parameters.next(Post.self)
    }
    
    // POST POST
    func postPost(_ request: Request, _ dto: PostDTO)throws -> Future<Post> {
        let appHeaders = try request.getAppHeaders()
        
        let post = Post(deviceID: appHeaders.deviceID,
                        text: dto.text,
                        updatedAt: dto.updatedAt,
                        pushTokenID: nil,
                        numberOfComments: nil,
                        numberOfLikes: nil,
                        numberOfDislikes: nil,
                        imageIds: dto.imageIds,
                        videosId: nil,
                        coordinate2D: dto.coordinate2D,
                        geolocation: nil,
                        channelID: nil,
                        likedBy: nil,
                        dislikedBy: nil)
        
        return post.create(on: request).flatMap { newPost in
            let postID = try newPost.requireID()
            
            let _ = Device.get(on: request, deviceID: appHeaders.deviceID).flatMap(to: Device.self) { fetchedDevice in
                guard let existingDevice = fetchedDevice else {
                    throw Abort(HTTPStatus.notFound)
                }
                
                if let pushTokenID = existingDevice.pushTokenID {
                    // Create notification event
                    NotificationEvent.create(on: request, pushTokenID: pushTokenID, eventID: postID)
                }
                
                return Future.map(on: request) { existingDevice }
            }
            
            // Create or update my post filter
            PostFilter.create(on: request, postID: postID, deviceID: appHeaders.deviceID, type: .myPost)
            
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
    
    // DELETE POST
    func deletePost(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(Post.self).delete(on: request).flatMap(to: HTTPStatus.self) { post in
            if let postID = post.id {
                // Delete associated notification events
                let _ = NotificationEvent.query(on: request).filter(\NotificationEvent.eventID, .equal, postID).delete()
                
                // Delete associate filters
                let _ = PostFilter.query(on: request).filter(\PostFilter.postID == postID).delete()
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
