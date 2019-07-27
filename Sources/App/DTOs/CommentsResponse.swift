import Vapor

struct CommentsResponse: Codable {
    var comments: [Comment]
}
extension CommentsResponse: Content { }
