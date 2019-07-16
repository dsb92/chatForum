import Vapor
import Fluent
import FCM

protocol PushMessage {
    var eventID: UUID? { get }
    var title: String { get }
    var body: String { get }
}

protocol PushOnLikes: PushMessage {
    var newLikeMessage: String { get }
    var newDislikeMessage: String { get }
    var numberOfLikes: Int? { get }
    var numberOfDislikes: Int? { get }
}

extension PushOnLikes {
    var title: String {
        if (self.numberOfDislikes ?? 0) > 0 {
            return newLikeMessage + ", " + newDislikeMessage
        } else {
            return newLikeMessage
        }
    }
}

protocol PushProvider {
    func sendPush(on request: Request, notification: Notification)throws -> Future<Notification>
}

protocol PushManageable {
    var pushProvider: PushProvider! { get }
    func sendPush(on request: Request, eventID: UUID, title: String, body: String)
    func sendPush(on request: Request, pushMessage: PushOnLikes, likesManager: LikesManager)
}

extension PushManageable {    
    func sendPush(on request: Request, eventID: UUID, title: String, body: String) {
        // Send push to any subscribers
        let fetchedEvent = NotificationEvent
            .query(on: request)
            .filter(\.eventID, .equal, eventID)
            .first()
        let _ = fetchedEvent.flatMap { fetched -> EventLoopFuture<NotificationEvent?> in
            if let fetched = fetched {
                let _ = fetched.subscriber.get(on: request).flatMap { pushToken -> EventLoopFuture<PushToken> in
                    let _ = try self.pushProvider.sendPush(on: request, notification: Notification(token: pushToken.token, title: title, body: body))
                    return Future.map(on: request) { return pushToken }
                }
            }
            return Future.map(on: request) { return fetched }
        }
    }
    
    func sendPush(on request: Request, pushMessage: PushOnLikes, likesManager: LikesManager) {
        if let eventID = pushMessage.eventID, likesManager.shouldSendPush(numberOfLikes: pushMessage.numberOfLikes) || likesManager.shouldSendPush(numberOfDislikes: pushMessage.numberOfDislikes) {
            let title = pushMessage.title
            let body = pushMessage.body
            
            self.sendPush(on: request, eventID: eventID, title: title, body: body)
        }
    }
}
