import Vapor
import FluentPostgreSQL

final class Channel: PostgreModel {
    var id: UUID?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Channel {
    static var idKey: WritableKeyPath<Channel, UUID?> {
        return \.id
    }
}

extension Channel {
    var posts: Children<Channel, Post> {
        return children(\.channelID)
    }
}
