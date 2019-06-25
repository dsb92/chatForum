import FluentPostgreSQL
import Foundation
import Vapor

struct CommentAddNumberOfComments: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Comment.self, on: conn, closure: { builder in
            builder.field(for: \.numberOfComments, type: .integer, .default(.literal(0)))
        })
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Comment.self, on: conn) { builder in
            builder.deleteField(for: \.numberOfComments)
        }
    }
}
