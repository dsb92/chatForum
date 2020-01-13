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
    try router.register(collection: DeviceController())
    try router.register(collection: AllowedDeviceController())
    try router.register(collection: BlockedDeviceController())
    try router.register(collection: PushTokenController())
    try router.register(collection: NotificationController())
    try router.register(collection: NotificationEventController())
    try router.register(collection: PostFilterController())
    try router.register(collection: LocationController())
    try router.register(collection: ChannelController())
    router.get { (request) in
        return "Running Vapor!"
    }
}
