import FluentPostgreSQL
import Foundation
import Vapor

final class NotificationEvent: Content {
    var id: UUID?
    var pushTokenID: UUID
    var eventID: UUID
    
    init(pushTokenID: UUID, eventID: UUID) {
        self.pushTokenID = pushTokenID
        self.eventID = eventID
    }
}

extension NotificationEvent: Migration {}
extension NotificationEvent: Parameter {}
extension NotificationEvent: Model {
    // Need to declare which database
    typealias Database = PostgreSQLDatabase
    
    static var idKey: WritableKeyPath<NotificationEvent, UUID?> {
        return \.id
    }
}

extension NotificationEvent {
    var subscriber: Parent<NotificationEvent, PushToken> {
        return parent(\.pushTokenID)
    }
}

extension NotificationEvent {
    struct all: Content {
        var notificationEvents: [NotificationEvent]
    }
}
