import Vapor
import Fluent
import FCM

protocol PushProvider {
    func sendPush(on request: Request, notification: Notification)throws -> Future<Notification>
}

protocol PushManageable {
    var pushProvider: PushProvider! { get }
}
