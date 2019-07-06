import FluentPostgreSQL
import Foundation
import Vapor

final class PushToken: Content {
    var id: UUID?
    var token: String
    
    init(token: String) {
        self.token = token
    }
}

extension PushToken: Parameter {}
extension PushToken: Migration {}

extension PushToken: Model {
    typealias Database = PostgreSQLDatabase
    
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
