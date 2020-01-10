import FluentPostgreSQL
import Vapor
import Authentication
import DungeonChatCore

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())

    // register Authentication provider
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a PostgreSQL database
    let postgresqlConfig = PostgreSQLDatabaseConfig(
        hostname: CurrentPostgreSQLConfig.hostname,
        port: CurrentPostgreSQLConfig.port,
        username: CurrentPostgreSQLConfig.username,
        database: CurrentPostgreSQLConfig.database,
        password: CurrentPostgreSQLConfig.password,
        transport: CurrentPostgreSQLConfig.transport
    )
    let postgresql = PostgreSQLDatabase(config: postgresqlConfig)

    // Register the configured PostgreSQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: postgresql, as: .psql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: AuthToken.self, database: .psql)
    migrations.add(model: Campaign.self, database: .psql)
    migrations.add(model: CampaignUser.self, database: .psql)
    services.register(migrations)
}
