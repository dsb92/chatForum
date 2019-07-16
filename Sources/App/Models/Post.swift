import FluentPostgreSQL
import Foundation
import Vapor

final class Post: Content {
    var id: UUID?
    var text: String
    var updatedAt: String
    var backgroundColorHex: String
    var numberOfComments: Int?
    var numberOfLikes: Int?
    var numberOfDislikes: Int?
    var imageIds: [UUID]?
    var videoIds: [UUID]?
    var pushTokenID: UUID?
    
    init(text: String, updatedAt: String, backgroundColorHex: String, numberOfComments: Int?, numberOfLikes: Int?, numberOfDislikes: Int?, imageIds: [UUID]?, videosId: [UUID]?, pushTokenID: UUID?) {
        self.text = text
        self.updatedAt = updatedAt
        self.backgroundColorHex = backgroundColorHex
        self.numberOfComments = numberOfComments
        self.numberOfLikes = numberOfLikes
        self.numberOfDislikes = numberOfDislikes
        self.imageIds = imageIds
        self.videoIds = videosId
        self.pushTokenID = pushTokenID
    }
}

extension Post: Parameter {}
extension Post: Migration {}

extension Post: Model {
    typealias Database = PostgreSQLDatabase
    
    static var idKey: WritableKeyPath<Post, UUID?> {
        return \.id
    }
}

extension Post {
    // this post's related comments
    var comments: Children<Post, Comment> {
        return children(\.postID)
    }
}

extension Post {
    struct Likes: Content {
        var numberOfLikes: Int
    }
    struct Dislikes: Content {
        var numberOfDislikes: Int
    }
}

extension Post: Comparable {
    static func < (lhs: Post, rhs: Post) -> Bool {
        return lhs.updatedAt.toDate().compare(rhs.updatedAt.toDate()) == .orderedAscending
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.updatedAt.toDate().compare(rhs.updatedAt.toDate()) == .orderedSame
    }
}

extension Post: PushOnLikes {
    var eventID: UUID? {
        return self.id
    }
    
    var newLikeMessage: String {
        return LocalizationManager.newLikeOnPost.replacingOccurrences(of: "X", with: String(self.numberOfLikes ?? 0))
    }
    
    var newDislikeMessage: String {
        return LocalizationManager.newDislikeOnPost.replacingOccurrences(of: "X", with: String(self.numberOfDislikes ?? 0))
    }
    
    var body: String {
        return self.text
    }
}
