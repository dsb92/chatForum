import FluentPostgreSQL
import Vapor
import Authentication

final class User: PostgreModel {
    var id: UUID?
    var email: String
    var password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User: Model {
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
