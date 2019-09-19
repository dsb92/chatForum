import Vapor

struct DevicesResponse: Codable {
    var devices: [Device]
}
extension DevicesResponse: Content {}
