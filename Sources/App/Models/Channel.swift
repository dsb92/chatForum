import Vapor
import FluentPostgreSQL

final class Channel: Content {
    var id: UUID?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Channel: Parameter {}
extension Channel: Migration {}

extension Channel: Model {
    typealias Database = PostgreSQLDatabase
    
    static var idKey: WritableKeyPath<Channel, UUID?> {
        return \.id
    }
}

extension Channel {
    var posts: Children<Channel, Post> {
        return children(\.channelID)
    }
}
