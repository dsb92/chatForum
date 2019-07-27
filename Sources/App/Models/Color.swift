import FluentPostgreSQL
import Foundation
import Vapor

final class Color: PostgreModel {
    var id: UUID?
    var hexString: String?
    
    init(hexString: String) {
        self.hexString = hexString
    }
}

extension Color {
    static var idKey: WritableKeyPath<Color, UUID?> {
        return \.id
    }
}
