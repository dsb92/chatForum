import Vapor
import Fluent

final class BlockedDeviceController: RouteCollection {
    func boot(router: Router) throws {
        let blockedDevices = router.grouped("blockedDevices")
        blockedDevices.get(use: getBlockedDevices)
        blockedDevices.post(BlockedDevice.self, use: postBlockedDevice)
        blockedDevices.delete(BlockedDevice.parameter, use: deleteBlockedDevice)
    }
    
    func getBlockedDevices(_ request: Request)throws -> Future<BlockedDevicesResponse> {
        return BlockedDevice.query(on: request).all().flatMap { blockedDevices in
            return Future.map(on: request) { return BlockedDevicesResponse(blockedDevices: blockedDevices) }
        }
    }
    
    func postBlockedDevice(_ request: Request, blockedDevice: BlockedDevice)throws -> Future<BlockedDevice> {
        return blockedDevice.create(on: request)
    }
    
    func deleteBlockedDevice(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(BlockedDevice.self).delete(on: request).transform(to: .noContent)
    }
}
