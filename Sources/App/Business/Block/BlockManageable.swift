import Vapor
import Fluent

protocol BlockManageable {
    func filteredBlockedPostsOnRequest(_ request: Request, deviceID: UUID) throws -> Future<[Post]>
    func filteredBlockedCommentsOnRequest(_ request: Request, post: Post, deviceID: UUID) throws -> Future<[Comment]>
}

extension BlockManageable {
    func filteredBlockedPostsOnRequest(_ request: Request, deviceID: UUID) throws -> Future<[Post]> {
        // Filter out by devices that are blocked and not supposed to be seen by user with passed deviceID from header
        let blocked = Post.query(on: request).join(\BlockedDevice.deviceID, to: \Post.deviceID).filter(\BlockedDevice.blockedDeviceID == deviceID).all()
        
        let val = blocked.flatMap(to: [Post].self) { blockedPosts in
            return Post.query(on: request).all().flatMap(to: [Post].self) { posts in
                var match = posts
                for blockedPost in blockedPosts {
                    match.removeAll(where: { $0.id == blockedPost.id })
                }
                
                return Future.map(on: request) { match }
            }
        }
        
        return val
    }

    func filteredBlockedCommentsOnRequest(_ request: Request, post: Post, deviceID: UUID) throws -> Future<[Comment]>{
        // Filter out by devices that are blocked and not supposed to be seen by user with passed deviceID from header
        let blocked = Comment.query(on: request).join(\BlockedDevice.deviceID, to: \Comment.deviceID).filter(\BlockedDevice.blockedDeviceID == deviceID).all()
        
        let val = blocked.flatMap(to: [Comment].self) { blockedComments in
            return try post.comments.query(on: request).all().flatMap(to: [Comment].self) { comments in
                var match = comments
                for blockedComment in blockedComments {
                    match.removeAll(where: { $0.id == blockedComment.id })
                }
                
                return Future.map(on: request) { match }
            }
        }
        
        return val
    }
}
