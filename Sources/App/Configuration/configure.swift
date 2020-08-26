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
    
    // Load enviroment if any
    Environment.dotenv()
    
    try services.register(FluentPostgreSQLProvider())
    
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    var middlewares = MiddlewareConfig.default()
    middlewares.use(StreamableFileMiddleware.self) // Serve files from Public directory
    middlewares.use(SecretMiddleware.self)
    middlewares.use(VersionMiddleware.self)
    
    services.register(middlewares)
    services.register(StreamableFileMiddleware.self)
    services.register(SecretMiddleware.self)
    services.register(VersionMiddleware.self)
    try services.register(AuthenticationProvider())
    
    // Configure a database
    guard let databaseUrl = Environment.get("DATABASE_URL") else { throw Abort(.internalServerError, reason: "Missing database connection") }
    var databases = DatabasesConfig()
    if env == .development {
        databases.enableLogging(on: .psql)
    }
    let databaseConfig = PostgreSQLDatabaseConfig(url: databaseUrl)!
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)
    
    // Migrations
    var migrations = MigrationConfig()
    migrations.add(model: Post.self, database: .psql)
    migrations.add(model: Comment.self, database: .psql)
    migrations.add(model: AllowedDevice.self, database: .psql)
    migrations.add(model: BlockedDevice.self, database: .psql)
    migrations.add(model: Channel.self, database: .psql)
    migrations.add(model: Device.self, database: .psql)
    migrations.add(model: Location.self, database: .psql)
    migrations.add(model: Notification.self, database: .psql)
    migrations.add(model: NotificationEvent.self, database: .psql)
    migrations.add(model: PostFilter.self, database: .psql)
    migrations.add(model: PushToken.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    
    services.register(migrations)
    
    var commands = CommandConfig.default()
    commands.useFluentCommands()
    services.register(commands)
    
    // There is a default limit of 1 million bytes for incoming requests. Override it her
    services.register(NIOServerConfig.default(maxBodySize: 20_000_000))
    
    Post.defaultDatabase = .psql
    Comment.defaultDatabase = .psql
    Token.defaultDatabase = .psql
    User.defaultDatabase = .psql
    PushToken.defaultDatabase = .psql
    Notification.defaultDatabase = .psql
    NotificationEvent.defaultDatabase = .psql
    Location.defaultDatabase = .psql
    Channel.defaultDatabase = .psql
    Device.defaultDatabase = .psql
    BlockedDevice.defaultDatabase = .psql
    AllowedDevice.defaultDatabase = .psql
    PostFilter.defaultDatabase = .psql
    
    // Configure FCM
    let directory = DirectoryConfig.detect()
    guard let fcmServiceAccountEncoded = Environment.get("FIREBASE_SERVICE_ACCOUNT_BASE64") else { throw Abort(.internalServerError, reason: "Missing Firebase service account setup") }
    
    if let decodedData = Data(base64Encoded: fcmServiceAccountEncoded), let decodedString = String(data: decodedData, encoding: .utf8) {
        // Create tmp dir
        let dir = directory.workDir + "tmp"
        do {
            try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
        
        // Create tmp file
        let path = dir + "/loomi-485e6-firebase-adminsdk-qc49a-b5a8814440.json"
        if !FileManager.default.fileExists(atPath:path){
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
        
        try decodedString.write(toFile: path, atomically: true, encoding: .utf8)
        let fcm = FCM(pathToServiceAccountKey: path)
        services.register(fcm, as: FCM.self)
    }
}
