import FluentPostgreSQL
import Foundation
import Vapor

struct DeviceAddPushTokenID: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Device.self, on: conn, closure: { builder in
            builder.field(for: \.pushTokenID, type: .uuid)
        })
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Device.self, on: conn) { builder in
            builder.deleteField(for: \.pushTokenID)
        }
    }
}
