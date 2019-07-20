import Vapor
import Fluent
import FCM

struct FCMProvider: PushProvider {
    func sendPush(on request: Request, notification: Notification) throws -> EventLoopFuture<Notification> {
        let fcm = try request.make(FCM.self)
        let token = notification.token
        let fcmNotification: FCMNotification? = (notification.isSilent ?? false) ? nil : FCMNotification(title: notification.title, body: notification.body)
        let message = FCMMessage(token: token, notification: fcmNotification)
        message.apns = FCMApnsConfig(headers: [:], aps: FCMApnsApsObject(alert: nil, badge: nil, sound: nil, contentAvailable: notification.isSilent, category: notification.category, threadId: nil, mutableContent: false))
        
        if let data = notification.data {
            message.data = data
        }
        
        return try fcm.sendMessage(request.client(), message: message).flatMap(to: Notification.self) { response in
            return notification.create(on: request)
        }
    }
}
