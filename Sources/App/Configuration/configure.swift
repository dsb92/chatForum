import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(
_ config: inout Config,
_ env: inout Environment,
_ services: inout Services
) throws {
    
    // This provider handles operations such as creating tables in our database when we boot the application.
    try services.register(FluentPostgreSQLProvider())
    
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)
    
    var databases = DatabasesConfig()
    let config = PostgreSQLDatabaseConfig(hostname: "localhost", username: "davidbuhauer", database: "chatForum")
    databases.add(database: PostgreSQLDatabase(config: config), as: .psql)
    services.register(databases)
    
    var migrations = MigrationConfig()
    migrations.add(model: Post.self, database: .psql)
    migrations.add(model: Comment.self, database: .psql)
    services.register(migrations)
    
    var commands = CommandConfig.default()
    commands.useFluentCommands()
    services.register(commands)
}
