import FluentPostgreSQL
import Foundation
import Vapor

final class Color: Content {
    var id: UUID?
    var hexString: String?
    
    init(hexString: String) {
        self.hexString = hexString
    }
}

extension Color: Parameter {}
extension Color: Migration {}

extension Color: Model {
    typealias Database = PostgreSQLDatabase
    
    static var idKey: WritableKeyPath<Color, UUID?> {
        return \.id
    }
}
