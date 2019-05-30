import Vapor
import Fluent
import Authentication

extension Router {
    var authenticated: Router {
        let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
        let authedRoutes = self.grouped(tokenAuthenticationMiddleware)
        return authedRoutes
    }
}

extension Request {
    func authenticated() throws -> User {
        return try self.requireAuthenticated(User.self)
    }
    
    func authenticate() throws {
        let _ = try self.authenticated()
    }
}
