import FluentPostgreSQL
import Foundation
import Vapor

struct DeviceAddAppInfo: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Device.self, on: conn, closure: { builder in
            builder.field(for: \.deviceID)
            builder.field(for: \.appVersion, type: .text)
            builder.field(for: \.appPlatform, type: .text)
        })
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Device.self, on: conn) { builder in
            builder.deleteField(for: \.deviceID)
            builder.deleteField(for: \.appVersion)
            builder.deleteField(for: \.appPlatform)
        }
    }
}
