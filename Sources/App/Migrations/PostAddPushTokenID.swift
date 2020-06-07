//import FluentPostgreSQL
//import Foundation
//import Vapor
//
//struct PostAddPushTokenID: Migration {
//    typealias Database = PostgreSQLDatabase
//    
//    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
//        return Database.update(Post.self, on: conn, closure: { builder in
//            builder.field(for: \.pushTokenID)
//        })
//    }
//    
//    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
//        return Database.update(Post.self, on: conn) { builder in
//            builder.deleteField(for: \.pushTokenID)
//        }
//    }
//}
