import FluentPostgreSQL
import Foundation
import Vapor

struct CommentAddUpdatedAt: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Comment.self, on: conn, closure: { builder in
            builder.field(for: \.updatedAt, type: .text, .default(.literal("")))
        })
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Comment.self, on: conn) { builder in
            builder.deleteField(for: \.updatedAt)
        }
    }
}

struct PostAddUpdatedAt: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Post.self, on: conn, closure: { builder in
            builder.field(for: \.updatedAt, type: .text, .default(.literal("")))
        })
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Post.self, on: conn) { builder in
            builder.deleteField(for: \.updatedAt)
        }
    }
}
