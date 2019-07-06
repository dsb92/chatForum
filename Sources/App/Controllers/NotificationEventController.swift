import Vapor
import Fluent

final class NotificationEventController: RouteCollection {
    func boot(router: Router) throws {
        let notEvents = router.grouped("notificationEvents")
        
        notEvents.post(NotificationEvent.self, use: postNotificationEvent)
        notEvents.get(use: getNotificationEvents)
    }
    
    func postNotificationEvent(_ request: Request, _ notificationEvent: NotificationEvent)throws -> Future<NotificationEvent> {
        return notificationEvent.create(on: request)
    }
    
    func getNotificationEvents(_ request: Request)throws -> Future<NotificationEvent.all> {
        let val = NotificationEvent.query(on: request).all()
        return val.flatMap { notificationEvents in
            let all = NotificationEvent.all(notificationEvents: notificationEvents)
            return Future.map(on: request) { return all }
        }
    }
}
