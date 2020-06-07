import Vapor
import Fluent

final class PushTokenController: RouteCollection {
    
    func boot(router: Router) throws {
        let pushToken = router.grouped("pushTokens")
        
        pushToken.post(PushToken.self, use: createOrUpdatePushToken)
        pushToken.put(PushToken.self, use: createOrUpdatePushToken)
        pushToken.delete(PushToken.parameter, use: deletePushToken)
        pushToken.get(use: getPushTokens)
    }
    
    func createOrUpdatePushToken(_ request: Request, pushToken: PushToken)throws -> Future<PushToken> {
        let appHeaders = try request.getAppHeaders()
        return pushToken.save(on: request).flatMap { created in
            let id = try created.requireID()
            Device.create(on: request, deviceID: appHeaders.deviceID, appVersion: appHeaders.version, appPlatform: appHeaders.platform, pushTokenID: id)
            return Future.map(on: request) { return created }
        }
    }
    
    func deletePushToken(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(PushToken.self).delete(on: request).transform(to: .noContent)
    }
    
    func getPushTokens(_ request: Request)throws -> Future<PushToken.all> {
        let val = PushToken.query(on: request).all()
        return val.flatMap { pushTokens in
            let all = PushToken.all(pushTokens: pushTokens)
            return Future.map(on: request) { return all }
        }
    }
}
