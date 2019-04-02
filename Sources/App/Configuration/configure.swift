import FluentPostgreSQL
import Vapor

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
    
    let middlewares = MiddlewareConfig.default()
    services.register(middlewares)
    
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
    migrations.add(model: Color.self, database: .psql)
    
//    migrations.add(migration: PostAddUpdatedAt.self, database: .psql)
//    migrations.add(migration: CommentAddUpdatedAt.self, database: .psql)
//    migrations.add(migration: PostAddBackgroundColorHex.self, database: .psql)
    migrations.add(migration: PostAddNumberOfComments.self, database: .psql)
    
    services.register(migrations)
    
    var commands = CommandConfig.default()
    commands.useFluentCommands()
    services.register(commands)
    
    Post.defaultDatabase = .psql
    Comment.defaultDatabase = .psql
}
