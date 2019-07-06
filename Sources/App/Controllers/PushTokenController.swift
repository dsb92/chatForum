import Vapor
import Fluent

final class PushTokenController: RouteCollection {
    
    func boot(router: Router) throws {
        let pushToken = router.grouped("pushTokens")
        
        pushToken.post(PushToken.self, use: postPushToken)
        pushToken.put(PushToken.self, use: putPushToken)
        pushToken.delete(PushToken.parameter, use: deletePushToken)
        pushToken.get(use: getPushTokens)
    }
    
    func postPushToken(_ request: Request, _ pushToken: PushToken)throws -> Future<PushToken> {
        return pushToken.create(on: request)
    }
    
    func putPushToken(_ request: Request, pushToken: PushToken)throws -> Future<PushToken> {
        return pushToken.update(on: request)
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
