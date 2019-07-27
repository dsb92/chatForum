import Vapor

struct ChannelsResponse: Codable {
    var channels: [Channel]
}
extension ChannelsResponse: Content {}
