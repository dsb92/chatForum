import FluentPostgreSQL
import Foundation
import Vapor

struct CommentAddNumberOfLikes: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Comment.self, on: conn, closure: { builder in
            builder.field(for: \.numberOfLikes, type: .integer, .default(.literal(0)))
        })
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Comment.self, on: conn) { builder in
            builder.deleteField(for: \.numberOfLikes)
        }
    }
}
