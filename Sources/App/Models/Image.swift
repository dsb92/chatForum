import FluentPostgreSQL
import Foundation
import Vapor

final class Image: Content {
    var id: UUID?
    var imageRaw: Data
    
    init(imageRaw: Data) {
        self.imageRaw = imageRaw
    }
}

extension Image: Parameter {}
extension Image: Migration {}

extension Image: Model {
    typealias Database = PostgreSQLDatabase
    
    static var idKey: WritableKeyPath<Image, UUID?> {
        return \.id
    }
}
