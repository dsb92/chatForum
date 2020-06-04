import FluentPostgreSQL
import Foundation
import Vapor

final class Device: PostgreModel {
    var id: UUID?
    var deviceID: UUID
    var appVersion: String
    var appPlatform: String
    
    init(deviceID: UUID, appVersion: String, appPlatform: String) {
        self.deviceID = deviceID
        self.appVersion = appVersion
        self.appPlatform = appPlatform
    }
}

extension Device {
    static var idKey: WritableKeyPath<Device, UUID?> {
        return \.id
    }
}

extension Device {
    static func create(on request: Request, deviceID: UUID, appVersion: String, appPlatform: String) {
        let _ = Device.query(on: request).filter(\Device.deviceID == deviceID).first().flatMap(to: Device.self) { device in
            if let device = device {
                device.appVersion = appVersion
                device.appPlatform = appPlatform
                return device.save(on: request)
            } else {
                return Device.query(on: request).create(Device(deviceID: deviceID, appVersion: appVersion, appPlatform: appPlatform))
            }
        }
    }
}
