import FluentPostgreSQL
import Vapor
import Authentication

final class User: Content {
    var id: UUID?
    var email: String
    var password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

extension User: Parameter {}
extension User: Migration {}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User: Model {
    typealias Database = PostgreSQLDatabase
    
    static var idKey: WritableKeyPath<User, UUID?> {
        return \.id
    }
}

extension User {
    struct Public: Content {
        let id: UUID
        let email: String
    }
}
