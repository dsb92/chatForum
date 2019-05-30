import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    try router.register(collection: UserController())
    try router.register(collection: PostController())
    try router.register(collection: CommentController())
    try router.register(collection: ImageController())
    try router.register(collection: VideoController())
    try router.register(collection: ColorController())
    try router.register(collection: SettingsController())
    router.get { (request) in
        return "Running Vapor!"
    }
}
