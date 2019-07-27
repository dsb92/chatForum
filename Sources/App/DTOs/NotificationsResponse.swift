import Vapor

struct NotificationsResponse: Codable {
    var notifications: [Notification]
}
extension NotificationsResponse: Content{}
