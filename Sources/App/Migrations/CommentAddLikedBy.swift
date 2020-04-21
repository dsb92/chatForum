import FluentPostgreSQL
import Foundation
import Vapor

struct CommentAddLikedBy: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Comment.self, on: conn, closure: { builder in
            builder.field(for: \.likedBy, type: .array(.uuid), .default(.literal("{}")))
        })
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Comment.self, on: conn) { builder in
            builder.deleteField(for: \.likedBy)
        }
    }
}
