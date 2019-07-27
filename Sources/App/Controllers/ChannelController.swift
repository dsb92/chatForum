import Vapor
import Fluent

struct ChannelsResponse: Codable {
    var channels: [Channel]
}

extension ChannelsResponse: Content {}

final class ChannelController: RouteCollection {
    func boot(router: Router) throws {
        let channels = router.grouped("channels")
        channels.get(use: getChannels)
        channels.post(Channel.self, use: postChannel)
        channels.get(Channel.parameter, "posts", use: getPosts)
    }
    
    func getChannels(_ request: Request)throws -> Future<ChannelsResponse> {
        return Channel.query(on: request).all().flatMap { channels in
            return Future.map(on: request) { return ChannelsResponse(channels: channels) }
        }
    }
    
    func getPosts(_ request: Request)throws -> Future<PostsResponse> {
        return try request.parameters.next(Channel.self).flatMap(to: PostsResponse.self) { channel in
            let val = try channel.posts.query(on: request).all()
            return val.flatMap { posts in
                let all = PostsResponse(posts: posts.sorted(by: { (l, r) -> Bool in
                    return l > r
                }))
                return Future.map(on: request) { return all }
            }
        }
    }
    
    func postChannel(_ request: Request, channel: Channel)throws -> Future<Channel> {
        return channel.create(on: request)
    }
}
