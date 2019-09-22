import FluentPostgreSQL
import Foundation
import Vapor

struct CommentAddDeviceID: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Comment.self, on: conn, closure: { builder in
            builder.field(for: \.deviceID)
        })
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Comment.self, on: conn) { builder in
            builder.deleteField(for: \.deviceID)
        }
    }
}
