import FluentPostgreSQL
import Foundation
import Vapor

struct NotificationAddMigration: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Notification.self, on: conn, closure: { builder in
            builder.field(for: \.data)
            builder.field(for: \.category)
            builder.field(for: \.isSilent, type: .bool, .default(.literal(.boolean(._false))))
            builder.field(for: \.isMutableContent, type: .bool, .default(.literal(.boolean(.false))))
        })
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Notification.self, on: conn) { builder in
            builder.deleteField(for: \.data)
            builder.deleteField(for: \.category)
            builder.deleteField(for: \.isSilent)
            builder.deleteField(for: \.isMutableContent)
        }
    }
}
