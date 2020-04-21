import FluentPostgreSQL
import FluentSQL
import SQL
import Foundation
import Vapor
import Pagination

struct Coordinate2DPosition: Codable {
    var latitude: Double
    var longitude: Double
}

struct Geolocation: Codable {
    var country: String?
    var flagURL: String?
    var city: String?
}

extension Coordinate2DPosition: ReflectionDecodable, Equatable {
    static var leftExample = Coordinate2DPosition(latitude: 54.0123, longitude: 53.04131)
    static var rightExample = Coordinate2DPosition(latitude: 54.0123, longitude: 53.04131)
    
    static func reflectDecoded() throws -> (Coordinate2DPosition, Coordinate2DPosition) {
        return (Coordinate2DPosition.leftExample, Coordinate2DPosition.rightExample)
    }
    
    static func reflectDecodedIsLeft(_ item: Coordinate2DPosition) throws -> Bool {
        return item == Coordinate2DPosition.leftExample
    }
}

extension Geolocation: ReflectionDecodable, Equatable {
    static var leftExample = Geolocation(country: nil, flagURL: nil, city: nil)
    static var rightExample = Geolocation(country: "test", flagURL: "test", city: "test")
    
    static func reflectDecoded() throws -> (Geolocation, Geolocation) {
        return (Geolocation.leftExample, Geolocation.rightExample)
    }
    
    static func reflectDecodedIsLeft(_ item: Geolocation) throws -> Bool {
        return item == Geolocation.leftExample
    }
}

final class Post: PostgreModel, Identifiable {
    var id: UUID?
    var text: String
    var updatedAt: String
    var backgroundColorHex: String
    var numberOfComments: Int?
    var numberOfLikes: Int?
    var numberOfDislikes: Int?
    var imageIds: [UUID]?
    var videoIds: [UUID]?
    var deviceID: UUID?
    var pushTokenID: UUID?
    var coordinate2D: Coordinate2DPosition?
    var geolocation: Geolocation?
    var channelID: UUID?
    var likedBy: [UUID]?
    var dislikedBy: [UUID]?
    
    init(
        text: String,
        updatedAt: String,
        backgroundColorHex: String,
        numberOfComments: Int?,
        numberOfLikes: Int?,
        numberOfDislikes: Int?,
        imageIds: [UUID]?,
        videosId: [UUID]?,
        deviceID: UUID?,
        pushTokenID: UUID?,
        coordinate2D: Coordinate2DPosition?,
        geolocation: Geolocation?,
        channelID: UUID?,
        likedBy: [UUID]?,
        dislikedBy: [UUID]?) {
        self.text = text
        self.updatedAt = updatedAt
        self.backgroundColorHex = backgroundColorHex
        self.numberOfComments = numberOfComments
        self.numberOfLikes = numberOfLikes
        self.numberOfDislikes = numberOfDislikes
        self.imageIds = imageIds
        self.videoIds = videosId
        self.deviceID = deviceID
        self.pushTokenID = pushTokenID
        self.coordinate2D = coordinate2D
        self.geolocation = geolocation
        self.channelID = channelID
        self.likedBy = likedBy
        self.dislikedBy = dislikedBy
    }
}

extension Post {
    static var idKey: WritableKeyPath<Post, UUID?> {
        return \.id
    }
}

extension Post {
    var comments: Children<Post, Comment> {
        return children(\.postID)
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

extension Post: Paginatable {
    static var defaultPageSorts: [PostgreSQLOrderBy] {
        return [
            Post.Database.querySort(Post.Database.queryField(.keyPath(\ Post.updatedAt)), Post.Database.querySortDirectionDescending)
        ]
    }
}
