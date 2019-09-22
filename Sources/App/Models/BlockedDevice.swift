import FluentPostgreSQL
import Foundation
import Vapor

final class BlockedDevice: PostgreModel {
    var id: UUID?
    var deviceID: UUID
    var blockedDeviceID: UUID
    
    init(deviceID: UUID, blockedDeviceID: UUID) {
        self.deviceID = deviceID
        self.blockedDeviceID = blockedDeviceID
    }
}

extension BlockedDevice {
    static var idKey: WritableKeyPath<BlockedDevice, UUID?> {
        return \.id
    }
}

extension BlockedDevice {
    var device: Parent<BlockedDevice, Device> {
        return parent(\.deviceID)
    }
}
