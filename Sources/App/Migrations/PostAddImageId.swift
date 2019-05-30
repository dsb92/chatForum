import FluentPostgreSQL
import Foundation
import Vapor

//struct PostAddImageId: Migration {
//    typealias Database = PostgreSQLDatabase
//
//    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
//        return Database.update(Post.self, on: conn, closure: { builder in
//            builder.field(for: \.imageId, type: .uuid, .default(.literal("00000000-0000-0000-0000-000000000000")))
//        })
//    }
//
//    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
//        return Database.update(Post.self, on: conn) { builder in
//            builder.deleteField(for: \.imageId)
//        }
//    }
//}

struct PostAddImageIds: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Post.self, on: conn, closure: { builder in
            builder.field(for: \.imageIds, type: .array(.uuid), .default(.literal("{}")))
        })
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Post.self, on: conn) { builder in
            builder.deleteField(for: \.imageIds)
        }
    }
}
