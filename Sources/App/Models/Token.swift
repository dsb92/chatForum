import FluentPostgreSQL
import Foundation
import Vapor
import Authentication

final class Token: PostgreModel {
    var id: UUID?
    var token: String
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
}

extension Token {
    static var idKey: WritableKeyPath<Token, UUID?> {
        return \.id
    }
}

extension Token {
    var user: Parent<Token, User> {
        return parent(\.userID)
    }
}

extension Token: BearerAuthenticatable {
    static var tokenKey: WritableKeyPath<Token, String> { return \Token.token }
}

extension Token: Authentication.Token {
    typealias UserType = User
    typealias UserIDType = User.ID
    
    static var userIDKey: WritableKeyPath<Token, User.ID> {
        return \Token.userID
    }
}
