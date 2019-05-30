import FluentPostgreSQL
import Foundation
import Vapor

struct PostAddVideoId: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Post.self, on: conn, closure: { builder in
            builder.field(for: \.videoId, type: .uuid, .default(.literal("00000000-0000-0000-0000-000000000000")))
        })
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Post.self, on: conn) { builder in
            builder.deleteField(for: \.videoId)
        }
    }
}
