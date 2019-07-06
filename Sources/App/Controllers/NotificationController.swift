import Vapor
import Fluent
import FCM

final class NotificationController: RouteCollection {
    
    func boot(router: Router) throws {
        let notifications = router.grouped("notifications")
        
        notifications.post(Notification.self, use: postNotification)
        notifications.get(use: getNotifications)
    }
    
    func postNotification(_ request: Request, _ notification: Notification)throws -> Future<Notification> {
        let fcm = try request.make(FCM.self)
        let token = notification.token
        let fcmNotification = FCMNotification(title: notification.title, body: notification.body)
        let message = FCMMessage(token: token, notification: fcmNotification)
        return try fcm.sendMessage(request.client(), message: message).flatMap(to: Notification.self) { response in
            return notification.create(on: request)
        }
    }
    
    func getNotifications(_ request: Request)throws -> Future<Notification.all> {
        let val = Notification.query(on: request).all()
        return val.flatMap { notifications in
            let all = Notification.all(notifications: notifications)
            return Future.map(on: request) { return all }
        }
    }
}
