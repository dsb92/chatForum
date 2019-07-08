import FluentPostgreSQL
import Foundation
import Vapor

final class Comment: Content {
    var id: UUID?
    var postID: UUID
    var parentID: UUID?
    var comment: String
    var updatedAt: String
    var numberOfLikes: Int?
    var numberOfDislikes: Int?
    var numberOfComments: Int?
    var pushTokenID: UUID?
    
    init(postID: UUID, parentID: UUID?, comment: String, updatedAt: String, numberOfLikes: Int?, numberOfDislikes: Int?, numberOfComments: Int?, pushTokenID: UUID?) {
        self.parentID = parentID
        self.postID = postID
        self.comment = comment
        self.updatedAt = updatedAt
        self.numberOfLikes = numberOfLikes
        self.numberOfDislikes = numberOfDislikes
        self.numberOfComments = numberOfComments
        self.pushTokenID = pushTokenID
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

extension Comment {
    // this comment's related Post
    var post: Parent<Comment, Post> {
        return parent(\.postID)
    }
}

extension Comment {
    // this comment's related Post
    var parent: Parent<Comment, Comment>? {
        return parent(\.parentID)
    }
}

extension Comment {
    var comments: Children<Comment, Comment>? {
        return children(\.parentID)
    }
}

extension Comment {
    struct Likes: Content {
        var numberOfLikes: Int
    }
    struct Dislikes: Content {
        var numberOfDislikes: Int
    }
}

extension Comment: Comparable {
    static func < (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.updatedAt.toDate().compare(rhs.updatedAt.toDate()) == .orderedAscending
    }
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.updatedAt.toDate().compare(rhs.updatedAt.toDate()) == .orderedSame
    }
}
