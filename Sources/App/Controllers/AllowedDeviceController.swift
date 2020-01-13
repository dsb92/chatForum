import Vapor
import Fluent

final class AllowedDeviceController: RouteCollection {
    func boot(router: Router) throws {
        let allowedDevices = router.grouped("allowedDevices")
        allowedDevices.get(use: getAllowedDevices)
        allowedDevices.post(AllowedDevice.self, use: postAllowedDevice)
        allowedDevices.put(AllowedDevice.self, use: putAllowedDevice)
        allowedDevices.delete(AllowedDevice.parameter, use: deleteAllowedDevice)
    }
    
    func getAllowedDevices(_ request: Request)throws -> Future<AllowedDevicesResponse> {
        return AllowedDevice.query(on: request).all().flatMap { allowedDevices in
            return Future.map(on: request) { return AllowedDevicesResponse(allowedDevices: allowedDevices) }
        }
    }
    
    func postAllowedDevice(_ request: Request, allowedDevice: AllowedDevice)throws -> Future<AllowedDevice> {
        return allowedDevice.create(on: request)
    }
    
    func putAllowedDevice(_ request: Request, allowedDevice: AllowedDevice)throws -> Future<AllowedDevice> {
        return allowedDevice.update(on: request)
    }
    
    func deleteAllowedDevice(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(AllowedDevice.self).delete(on: request).transform(to: .noContent)
    }
}
