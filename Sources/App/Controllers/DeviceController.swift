import Vapor
import Fluent

final class DeviceController: RouteCollection {
    func boot(router: Router) throws {
        let devices = router.grouped("devices")
        devices.get(use: getDevices)
        devices.post(Device.self, use: postDevice)
        devices.get(Device.parameter, "posts", use: getPosts)
        devices.delete(Device.parameter, use: deleteDevice)
    }
    
    func getDevices(_ request: Request)throws -> Future<DevicesResponse> {
        return Device.query(on: request).all().flatMap { devices in
            return Future.map(on: request) { return DevicesResponse(devices: devices) }
        }
    }
    
    func getPosts(_ request: Request)throws -> Future<PostsResponse> {
        return try request.parameters.next(Device.self).flatMap(to: PostsResponse.self) { device in
            let val = try device.posts.query(on: request).all()
            return val.flatMap { posts in
                let all = PostsResponse(posts: posts.sorted(by: { (l, r) -> Bool in
                    return l > r
                }))
                return Future.map(on: request) { return all }
            }
        }
    }
    
    func deleteDevice(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(Device.self).delete(on: request).flatMap(to: HTTPStatus.self) { device in
            // Delete associated posts
            return try device.posts.query(on: request).delete().transform(to: .noContent)
        }
    }
    
    func postDevice(_ request: Request, device: Device)throws -> Future<Device> {
        return device.create(on: request)
    }
}
