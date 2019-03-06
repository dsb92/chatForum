import Vapor
import Fluent

final class UserController: RouteCollection {
    // Register all 'users' routes
    func boot(router: Router) throws {
        let users = router.grouped("users")
        
        // Regiser each handler
        users.post(User.self, use: postUser)
        users.put(User.self, use: putUser)
        users.get(use: getUsers)
        users.get(User.parameter, use: getUser)
        users.delete(User.parameter, use: deleteUser)
    }
    
    // GET USERS
    func getUsers(_ request: Request)throws -> Future<[User]> {
        return User.query(on: request).all()
    }
    
    // GET USER
    func getUser(_ request: Request)throws -> Future<User> {
        return try request.parameters.next(User.self)
    }
    
    // POST USER
    func postUser(_ request: Request, _ user: User)throws -> Future<User> {
        return user.create(on: request)
    }
    
    // UPDATE USER
    func putUser(_ request: Request, user: User)throws -> Future<User> {
        return user.update(on: request)
    }
    
    // DELETE USER
    func deleteUser(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(User.self).delete(on: request).transform(to: .noContent)
    }
}

struct UserContent: Content {
    var username: String?
    var firstname: String?
    var lastname: String?
    var email: String?
    var password: String?
}
