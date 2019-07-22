import FluentPostgreSQL
import Foundation
import Vapor

struct PostAddLocation: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Post.self, on: conn, closure: { builder in
            builder.field(for: \.coordinate2D)
            builder.field(for: \.geolocation)
        })
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Post.self, on: conn) { builder in
            builder.deleteField(for: \.coordinate2D)
            builder.deleteField(for: \.geolocation)
        }
    }
}
