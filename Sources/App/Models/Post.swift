import FluentPostgreSQL
import Foundation
import Vapor

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
    static var rightExample = Geolocation(country: "Danmark", flagURL: "https://www.countryflags.io/be/shiny/64.png", city: "Aarhus")
    
    static func reflectDecoded() throws -> (Geolocation, Geolocation) {
        return (Geolocation.leftExample, Geolocation.rightExample)
    }
    
    static func reflectDecodedIsLeft(_ item: Geolocation) throws -> Bool {
        return item == Geolocation.leftExample
    }
}

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
    var coordinate2D: Coordinate2DPosition?
    var geolocation: Geolocation?
    
    init(text: String, updatedAt: String, backgroundColorHex: String, numberOfComments: Int?, numberOfLikes: Int?, numberOfDislikes: Int?, imageIds: [UUID]?, videosId: [UUID]?, pushTokenID: UUID?, coordinate2D: Coordinate2DPosition?, geolocation: Geolocation?) {
        self.text = text
        self.updatedAt = updatedAt
        self.backgroundColorHex = backgroundColorHex
        self.numberOfComments = numberOfComments
        self.numberOfLikes = numberOfLikes
        self.numberOfDislikes = numberOfDislikes
        self.imageIds = imageIds
        self.videoIds = videosId
        self.pushTokenID = pushTokenID
        self.coordinate2D = coordinate2D
        self.geolocation = geolocation
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
