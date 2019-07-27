import Vapor
import Fluent
import FCM

final class NotificationController: RouteCollection, PushManageable {
    var pushProvider: PushProvider!
    
    func boot(router: Router) throws {
        pushProvider = FCMProvider()
        
        let notifications = router.grouped("notifications")
        
        notifications.post(Notification.self, use: postNotification)
        notifications.get(use: getNotifications)
    }
    
    func postNotification(_ request: Request, _ notification: Notification)throws -> Future<Notification> {
        return try pushProvider.sendPush(on: request, notification: notification)
    }
    
    func getNotifications(_ request: Request)throws -> Future<NotificationsResponse> {
        let val = Notification.query(on: request).all()
        return val.flatMap { notifications in
            let all = NotificationsResponse(notifications: notifications)
            return Future.map(on: request) { return all }
        }
    }
}
