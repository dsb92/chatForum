import FluentPostgreSQL
import Foundation
import Vapor

final class Post: Content {
    var id: UUID?
    var text: String
    var updatedAt: String
    var backgroundColorHex: String
    
    init(text: String, updatedAt: String, backgroundColorHex: String) {
        self.text = text
        self.updatedAt = updatedAt
        self.backgroundColorHex = backgroundColorHex
    }
}

extension Post: Parameter {}
extension Post: Migration {}

extension Post: Model {
    typealias Database = PostgreSQLDatabase
    
    static var idKey: WritableKeyPath<Post, UUID?> {
        return \.id
    }
}

extension Post {
    // this post's related comments
    var comments: Children<Post, Comment> {
        return children(\.postID)
    }
}

extension Comment {
    // this comment's related Post
    var post: Parent<Comment, Post> {
        return parent(\.postID)
    }
}
