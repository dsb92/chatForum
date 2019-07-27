import Vapor

struct SettingsResponse: Codable {
    var colors: [Color]
}

extension SettingsResponse: Content { }
