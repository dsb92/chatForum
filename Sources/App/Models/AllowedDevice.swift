import FluentPostgreSQL
import Foundation
import Vapor

final class AllowedDevice: PostgreModel {
    var id: UUID?
    var version: String
    var platform: String
    
    init(version: String, platform: String) {
        self.version = version
        self.platform = platform
    }
}

extension AllowedDevice {
    static var idKey: WritableKeyPath<AllowedDevice, UUID?> {
        return \.id
    }
}
