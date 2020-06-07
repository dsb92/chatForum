import Vapor

struct CommentDTO: Content {
    var comment: String
    var postID: UUID
    var updatedAt: String
}
