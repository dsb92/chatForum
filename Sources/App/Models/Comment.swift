import FluentPostgreSQL
import Foundation
import Vapor
import Pagination

final class Comment: PostgreModel, Identifiable {
    var id: UUID?
    var postID: UUID
    var deviceID: UUID?
    var parentID: UUID?
    var comment: String
    var updatedAt: String
    var likedBy: [UUID]?
    var dislikedBy: [UUID]?
    var numberOfLikes: Int?
    var numberOfDislikes: Int?
    var numberOfComments: Int?
    var pushTokenID: UUID?
    
    init(
        postID: UUID,
        deviceID: UUID?,
        parentID: UUID?,
        comment: String,
        updatedAt: String,
        likedBy: [UUID]?,
        dislikedBy: [UUID]?,
        numberOfLikes: Int?,
        numberOfDislikes: Int?,
        numberOfComments: Int?,
        pushTokenID: UUID?) {
        self.deviceID = deviceID
        self.parentID = parentID
        self.postID = postID
        self.comment = comment
        self.updatedAt = updatedAt
        self.numberOfLikes = numberOfLikes
        self.numberOfDislikes = numberOfDislikes
        self.numberOfComments = numberOfComments
        self.likedBy = likedBy
        self.dislikedBy = dislikedBy
        self.pushTokenID = pushTokenID
    }
}

extension Comment {
    static var idKey: WritableKeyPath<Comment, UUID?> {
        return \.id
    }
}

extension Comment {
    var post: Parent<Comment, Post> {
        return parent(\.postID)
    }
}

extension Comment {
    var parent: Parent<Comment, Comment>? {
        return parent(\.parentID)
    }
}

extension Comment {
    var comments: Children<Comment, Comment>? {
        return children(\.parentID)
    }
}

extension Comment: Comparable {
    static func < (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.updatedAt.toDate().compare(rhs.updatedAt.toDate()) == .orderedAscending
    }
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Comment: PushOnLikes {
    var eventID: UUID? {
        return self.id
    }
    
    var newLikeMessage: String {
        return LocalizationManager.newLikeOnComment.replacingOccurrences(of: "X", with: String(self.numberOfLikes ?? 0))
    }
    
    var newDislikeMessage: String {
        return LocalizationManager.newDislikeOnComment.replacingOccurrences(of: "X", with: String(self.numberOfLikes ?? 0))
    }
    
    var body: String {
        return self.comment
    }
}

extension Comment: Paginatable {
    static var defaultPageSorts: [PostgreSQLOrderBy] {
        return [
            Comment.Database.querySort(Comment.Database.queryField(.keyPath(\ Comment.updatedAt)), Comment.Database.querySortDirectionAscending)
        ]
    }
}
