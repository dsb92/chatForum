import FluentPostgreSQL
import Foundation
import Vapor

final class Device: PostgreModel {
    var id: UUID?
    var deviceID: UUID
    var appVersion: String
    var appPlatform: String
    var pushTokenID: UUID?
    
    init(deviceID: UUID, appVersion: String, appPlatform: String, pushTokenID: UUID?) {
        self.deviceID = deviceID
        self.appVersion = appVersion
        self.appPlatform = appPlatform
        self.pushTokenID = pushTokenID
    }
}

extension Device {
    static var idKey: WritableKeyPath<Device, UUID?> {
        return \.id
    }
}

extension Device {
    static func create(on request: Request, deviceID: UUID, appVersion: String, appPlatform: String, pushTokenID: UUID) {
        let _ = get(on: request, deviceID: deviceID).flatMap(to: Device.self) { device in
            if let device = device {
                device.appVersion = appVersion
                device.appPlatform = appPlatform
                device.pushTokenID = pushTokenID
                return device.update(on: request)
            } else {
                return Device.query(on: request).create(Device(deviceID: deviceID, appVersion: appVersion, appPlatform: appPlatform, pushTokenID: pushTokenID))
            }
        }
    }
    
    static func get(on request: Request, deviceID: UUID) -> Future<Device?> {
        return Device.query(on: request).filter(\Device.deviceID == deviceID).first()
    }
}
