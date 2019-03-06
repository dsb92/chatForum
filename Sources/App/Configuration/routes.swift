import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    try router.register(collection: UserController())
    router.get { (request) in
        return "Running Vapor!"
    }
}
