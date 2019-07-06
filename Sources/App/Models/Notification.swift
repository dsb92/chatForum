import FluentPostgreSQL
import Foundation
import Vapor

final class Notification: Content {
    var id: UUID?
    var token: String
    var title: String
    var body: String
    
    init(token: String, title: String, body: String) {
        self.token = token
        self.title = title
        self.body = body
    }
}

extension Notification: Parameter {}
extension Notification: Migration {}

extension Notification: Model {
    typealias Database = PostgreSQLDatabase
    
    static var idKey: WritableKeyPath<Notification, UUID?> {
        return \.id
    }
}

extension Notification {
    struct all: Content {
        var notifications: [Notification]
    }
}
