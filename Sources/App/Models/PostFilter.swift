import FluentPostgreSQL
import Foundation
import Vapor

enum PostFilterType: Int, PostgreSQLRawEnum {
    case myPost
    case myLikes
    case myDislikes
    case myComments
}

final class PostFilter: PostgreModel {
    var id: UUID?
    var postID: UUID
    var deviceID: UUID
    var type: PostFilterType?
    
    init(postID: UUID, deviceID: UUID, type: PostFilterType?) {
        self.type = type
        self.postID = postID
        self.deviceID = deviceID
        self.type = type
    }
}

extension PostFilter {
    static var idKey: WritableKeyPath<PostFilter, UUID?> {
        return \.id
    }
}

extension PostFilter {
    static func create(on request: Request, postID: UUID, deviceID: UUID, type: PostFilterType) {
        let filter = PostFilter(postID: postID, deviceID: deviceID, type: type)
        let _ = PostFilter.query(on: request).create(filter)
    }
    
    static func deleteLike(on request: Request, postID: UUID, deviceID: UUID) {
        delete(on: request, postID: postID, deviceID: deviceID, of: .myLikes)
    }
    
    static func deleteDislike(on request: Request, postID: UUID, deviceID: UUID) {
        delete(on: request, postID: postID, deviceID: deviceID, of: .myDislikes)
    }
    
    private static func delete(on request: Request, postID: UUID, deviceID: UUID, of type: PostFilterType) {
        let _ = PostFilter.query(on: request).filter(\PostFilter.postID == postID).filter(\PostFilter.deviceID == deviceID).filter(\PostFilter.type == type).delete()
    }
}
