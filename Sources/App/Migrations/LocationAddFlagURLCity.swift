import FluentPostgreSQL
import Foundation
import Vapor

struct LocationAddFlagURLCity: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Location.self, on: conn, closure: { builder in
            builder.field(for: \.flagURL)
            builder.field(for: \.city)
        })
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Location.self, on: conn) { builder in
            builder.deleteField(for: \.flagURL)
            builder.deleteField(for: \.city)
        }
    }
}
