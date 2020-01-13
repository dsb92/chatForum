import Vapor

struct AllowedDevicesResponse: Codable {
    var allowedDevices: [AllowedDevice]
}
extension AllowedDevicesResponse: Content {}
