import Vapor
import Fluent
import FCM

struct FCMProvider: PushProvider {
    func sendPush(on request: Request, notification: Notification) throws -> EventLoopFuture<Notification> {
        let fcm = try request.make(FCM.self)
        let token = notification.token
        let fcmNotification = FCMNotification(title: notification.title, body: notification.body)
        let message = FCMMessage(token: token, notification: fcmNotification)
        return try fcm.sendMessage(request.client(), message: message).flatMap(to: Notification.self) { response in
            return notification.create(on: request)
        }
    }
}
