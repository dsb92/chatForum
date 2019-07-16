import Vapor
import Fluent

final class NotificationEventController: RouteCollection {
    func boot(router: Router) throws {
        let notEvents = router.grouped("notificationEvents")
        
        notEvents.post(NotificationEvent.self, use: postNotificationEvent)
        notEvents.get(use: getNotificationEvents)
        notEvents.delete(NotificationEvent.parameter, use: deleteNotificationEvent)
        notEvents.delete(use: deleteAllNotificationEvents)
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
    
    func deleteNotificationEvent(_ request: Request) throws -> Future<HTTPStatus> {
        return try request.parameters.next(NotificationEvent.self).delete(on: request).transform(to: .noContent)
    }
    
    //FOR TESTING ONLY
    func deleteAllNotificationEvents(_ request: Request) throws -> Future<HTTPStatus> {
        return NotificationEvent.query(on: request).all().flatMap(to: HTTPStatus.self) { all in
            all.forEach { let _ = $0.delete(on: request) }
            return Future.map(on: request) { return HTTPStatus.noContent }
        }
    }
}
