import FluentPostgreSQL
import Foundation
import Vapor

final class Comment: Content {
    var id: UUID?
    var postID: UUID
    var comment: String
    var updatedAt: String
    
    init(postID: UUID, comment: String, updatedAt: String) {
        self.postID = postID
        self.comment = comment
        self.updatedAt = updatedAt
    }
}

extension Comment: Migration {}
extension Comment: Parameter {}
extension Comment: Model {
    // Need to declare which database
    typealias Database = PostgreSQLDatabase
    
    static var idKey: WritableKeyPath<Comment, UUID?> {
        return \.id
    }
}
