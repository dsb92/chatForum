import FluentPostgreSQL
import Vapor
import Authentication
import FCM

/// Called before your application initializes.
public func configure(
_ config: inout Config,
_ env: inout Environment,
_ services: inout Services
) throws {
    
    try services.register(FluentPostgreSQLProvider())
    
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    var middlewares = MiddlewareConfig.default()
    middlewares.use(StreamableFileMiddleware.self) // Serve files from Public directory
    middlewares.use(SecretMiddleware.self)
    
    services.register(middlewares)
    services.register(StreamableFileMiddleware.self)
    services.register(SecretMiddleware.self)
    try services.register(AuthenticationProvider())
    
    // Configure a database
    var databases = DatabasesConfig()
    let databaseConfig: PostgreSQLDatabaseConfig
    
    if let url = Environment.get("DATABASE_URL") {
        databaseConfig = PostgreSQLDatabaseConfig(url: url)!
    } else {
        let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
        let username = Environment.get("DATABASE_USER") ?? "davidbuhauer"
        let password = Environment.get("DATABASE_PASSWORD") ?? "password"
        let databaseName: String
        let databasePort: Int
        if (env == .testing) {
            databaseName = "vapor-test"
            if let testPort = Environment.get("DATABASE_PORT") {
                databasePort = Int(testPort) ?? 5433
            } else {
                databasePort = 5433
            }
        } else {
            databaseName = Environment.get("DATABASE_DB") ?? "chatForum"
            databasePort = 5432
        }
        
        databaseConfig = PostgreSQLDatabaseConfig(
            hostname: hostname,
            port: databasePort,
            username: username,
            database: databaseName,
            password: hostname == "localhost" ? nil : password)
    }
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)
    
    // Migrations
    var migrations = MigrationConfig()
//    migrations.add(model: Post.self, database: .psql)
//    migrations.add(model: Comment.self, database: .psql)
//    migrations.add(model: Color.self, database: .psql)
//    migrations.add(model: Token.self, database: .psql)
//    migrations.add(model: User.self, database: .psql)
    migrations.add(model: PushToken.self, database: .psql)
    migrations.add(model: Notification.self, database: .psql)
    migrations.add(model: NotificationEvent.self, database: .psql)
    
//    migrations.add(migration: PostAddUpdatedAt.self, database: .psql)
//    migrations.add(migration: CommentAddUpdatedAt.self, database: .psql)
//    migrations.add(migration: PostAddBackgroundColorHex.self, database: .psql)
//    migrations.add(migration: PostAddNumberOfComments.self, database: .psql)
//    migrations.add(migration: PostAddImageId.self, database: .psql)
//    migrations.add(migration: PostAddImageIds.self, database: .psql)
//    migrations.add(migration: PostAddVideoIds.self, database: .psql)
//    migrations.add(migration: PostAddNumberOfLikes.self, database: .psql)
//    migrations.add(migration: PostAddNumberOfDislikes.self, database: .psql)
//    migrations.add(migration: CommentAddNumberOfLikes.self, database: .psql)
//    migrations.add(migration: CommentAddNumberOfDislikes.self, database: .psql)
    migrations.add(migration: CommentAddParentID.self, database: .psql)
    migrations.add(migration: CommentAddNumberOfComments.self, database: .psql)
    migrations.add(migration: CommentAddPushTokenID.self, database: .psql)
    migrations.add(migration: PostAddPushTokenID.self, database: .psql)
    migrations.add(migration: NotificationAddMigration.self, database: .psql)
    
    services.register(migrations)
    
    var commands = CommandConfig.default()
    commands.useFluentCommands()
    services.register(commands)
    
    // There is a default limit of 1 million bytes for incoming requests. Override it her
    services.register(NIOServerConfig.default(maxBodySize: 20_000_000))
    
    Post.defaultDatabase = .psql
    Comment.defaultDatabase = .psql
    Color.defaultDatabase = .psql
    Token.defaultDatabase = .psql
    User.defaultDatabase = .psql
    
    // Configure FCM
    let directory = DirectoryConfig.detect()
    let fcm = FCM(pathToServiceAccountKey: directory.workDir + "/tmp/chatforum-190fa-firebase-adminsdk-1a7j5-395f92428d.json")
    services.register(fcm, as: FCM.self)
}
