import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    try router.register(collection: UserController())
    try router.register(collection: PostController())
    try router.register(collection: CommentController())
    router.get { (request) in
        return "Running Vapor!"
    }
}
