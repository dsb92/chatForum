import Vapor
import Fluent

protocol BlockManageable {
    func filteredBlockedPostsOnRequest(_ request: Request) throws -> Future<[Post]>
    func filteredBlockedCommentsOnRequest(_ request: Request) throws -> Future<[Comment]>
}

extension BlockManageable {
    func filteredBlockedPostsOnRequest(_ request: Request) throws -> Future<[Post]> {
        guard let deviceIDString = request.http.headers["deviceID"].first, let deviceID = UUID(uuidString: deviceIDString) else { throw Abort.init(.badRequest) }
        
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
    
    func filteredBlockedCommentsOnRequest(_ request: Request) throws -> Future<[Comment]>{
        guard let deviceIDString = request.http.headers["deviceID"].first, let deviceID = UUID(uuidString: deviceIDString) else { throw Abort.init(.badRequest) }
        
        // Filter out by devices that are blocked and not supposed to be seen by user with passed deviceID from header
        let blocked = Comment.query(on: request).join(\BlockedDevice.deviceID, to: \Comment.deviceID).filter(\BlockedDevice.blockedDeviceID == deviceID).all()
        
        let val = blocked.flatMap(to: [Comment].self) { blockedComments in
            return Comment.query(on: request).all().flatMap(to: [Comment].self) { comments in
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
