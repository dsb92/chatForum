import FluentPostgreSQL
import Foundation
import Vapor

typealias NotificationPayload = [String: String]

final class Notification: PostgreModel {
    var id: UUID?
    var token: String
    var title: String
    var body: String
    var data: NotificationPayload?
    var category: String?
    var isSilent: Bool?
    var isMutableContent: Bool?
    
    init(token: String, title: String, body: String, data: NotificationPayload? = nil, category: String? = nil, isSilent: Bool? = nil, isMutableContent: Bool? = nil) {
        self.token = token
        self.title = title
        self.body = body
        self.data = data
        self.category = category
        self.isSilent = isSilent
        self.isMutableContent = isMutableContent
    }
}

extension Notification {
    static var idKey: WritableKeyPath<Notification, UUID?> {
        return \.id
    }
}
