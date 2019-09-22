import FluentPostgreSQL
import Foundation
import Vapor

final class Device: PostgreModel {
    var id: UUID?
}

extension Device {
    static var idKey: WritableKeyPath<Device, UUID?> {
        return \.id
    }
}

extension Device {
    var posts: Children<Device, Post> {
        return children(\.deviceID)
    }
}

extension Device {
    var comments: Children<Device, Comment> {
        return children(\.deviceID)
    }
}
