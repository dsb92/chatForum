import FluentPostgreSQL
import Foundation
import Vapor

final class Location: Content {
    var id: UUID?
    var postID: UUID
    var country: String
    var flagURL: String?
    var city: String?
    
    init(postID: UUID, country: String, flagURL: String?, city: String?) {
        self.postID = postID
        self.country = country
        self.flagURL = flagURL
        self.city = city
    }
}

extension Location: Parameter {}
extension Location: Migration {}

extension Location: Model {
    typealias Database = PostgreSQLDatabase
    
    static var idKey: WritableKeyPath<Location, UUID?> {
        return \.id
    }
}

extension Location {
    var post: Parent<Location, Post> {
        return parent(\.postID)
    }
}
