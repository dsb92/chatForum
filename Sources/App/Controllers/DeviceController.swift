import Vapor
import Fluent

final class DeviceController: RouteCollection {
    func boot(router: Router) throws {
        let devices = router.grouped("devices")
        devices.get(use: getDevices)
        devices.delete(Device.parameter, use: deleteDevice)
    }
    
    func getDevices(_ request: Request)throws -> Future<DevicesResponse> {
        return Device.query(on: request).all().flatMap { devices in
            return Future.map(on: request) { return DevicesResponse(devices: devices) }
        }
    }
    
    func deleteDevice(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(Device.self).delete(on: request).transform(to: .noContent)
    }
}
