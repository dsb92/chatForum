import Vapor

struct BlockedDevicesResponse: Codable {
    var blockedDevices: [BlockedDevice]
}
extension BlockedDevicesResponse: Content {}
