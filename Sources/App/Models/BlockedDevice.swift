import FluentPostgreSQL
import Foundation
import Vapor

final class BlockedDevice: PostgreModel {
    var id: UUID?
    var deviceID: UUID
    
    init(deviceID: UUID) {
        self.deviceID = deviceID
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
