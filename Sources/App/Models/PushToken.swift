import FluentPostgreSQL
import Foundation
import Vapor

final class PushToken: PostgreModel {
    var id: UUID?
    var token: String
    
    init(token: String) {
        self.token = token
    }
}

extension PushToken {
    static var idKey: WritableKeyPath<PushToken, UUID?> {
        return \.id
    }
}

extension PushToken {
    struct all: Content {
        var pushTokens: [PushToken]
    }
}

extension PushToken {
    var notificationEvents: Children<PushToken, NotificationEvent> {
        return children(\.pushTokenID)
    }
}
