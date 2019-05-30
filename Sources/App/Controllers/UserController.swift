import Vapor
import Crypto
import Random

final class UserController: RouteCollection {
    func boot(router: Router) throws {
        let user = router.grouped("user")
        
        user.post("register", use: register)
        user.post("login", use: login)
        
        user.authenticated.get("profile", use: profile)
        user.authenticated.get("logout", use: logout)
    }
    
    func register(_ request: Request) throws -> Future<User.Public> {
        return try request.content.decode(User.self).flatMap { user in
            let hasher = try request.make(BCryptDigest.self)
            let passwordHashed = try hasher.hash(user.password)
            let newUser = User(email: user.email, password: passwordHashed)
            return newUser.save(on: request).map { storedUser in
                return User.Public(
                    id: try storedUser.requireID(),
                    email: storedUser.email
                )
            }
        }
    }
    
    func login(_ request: Request) throws -> Future<Token> {
        return try request.content.decode(User.self).flatMap { user in
            return User.query(on: request).filter(\.email, .equal, user.email).first().flatMap { fetchedUser in
                guard let existingUser = fetchedUser else {
                    throw Abort(HTTPStatus.notFound)
                }
                let hasher = try request.make(BCryptDigest.self)
                if try hasher.verify(user.password, created: existingUser.password) {
                    return try Token
                        .query(on: request)
                        .filter(\Token.userID, .equal, existingUser.requireID())
                        .delete()
                        .flatMap { _ in
                            let tokenString = try URandom().generateData(count: 32).base64EncodedString()
                            let token = try Token(token: tokenString, userID: existingUser.requireID())
                            return token.save(on: request)
                    }
                } else {
                    throw Abort(HTTPStatus.unauthorized)
                }
            }
        }
    }
    
    func logout(_ req: Request) throws -> Future<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self)
        return try Token
            .query(on: req)
            .filter(\Token.userID, .equal, user.requireID())
            .delete()
            .transform(to: HTTPResponse(status: .ok))
    }
    
    func profile(_ request: Request) throws -> Future<String> {
        let user = try request.authenticated()
        return request.future("Welcome \(user.email)")
    }
}
