import Vapor

struct PostsResponse: Codable {
    var posts: [Post]
}
extension PostsResponse: Content { }
