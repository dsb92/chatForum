import FluentPostgreSQL
import Foundation
import Vapor

final class NotificationEvent: PostgreModel {
    var id: UUID?
    var pushTokenID: UUID
    var eventID: UUID
    
    init(pushTokenID: UUID, eventID: UUID) {
        self.pushTokenID = pushTokenID
        self.eventID = eventID
    }
}

extension NotificationEvent {
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

extension NotificationEvent {
    static func create(on request: Request, pushTokenID: UUID, eventID: UUID) {
        let event = NotificationEvent(pushTokenID: pushTokenID, eventID: eventID)
        let _ = NotificationEvent.query(on: request).save(event)
    }
}
