import FluentPostgreSQL
import Foundation
import Vapor

final class Comment: Content {
    var id: UUID?
    var postID: UUID
    var comment: String
    var updatedAt: String
    
    init(postID: UUID, comment: String, updatedAt: String) {
        self.postID = postID
        self.comment = comment
        self.updatedAt = updatedAt
    }
}

extension Comment: Migration {
    // Need to declare which database
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Comment.self, on: conn) { builder in
            builder.field(for: \.updatedAt, type: .varchar, .default(.literal("")))
        }
    }
    
    static func revert(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Comment.self, on: connection) { builder in
            builder.deleteField(for: \.updatedAt)
        }
    }
}
extension Comment: Parameter {}
extension Comment: Model {
    static var idKey: WritableKeyPath<Comment, UUID?> {
        return \.id
    }
}
