//
//  Application+Testable.swift
//  AppTests
//
//  Created by Vorona Vyacheslav on 1/13/20.
//

import App
import Vapor
import FluentPostgreSQL

extension Application {
    static func testable() throws -> Application {
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        try App.configure(&config, &env, &services)
        injectTestablePostgreSQL(&services)
        let app = try Application(config: config, environment: env, services: services)
        try App.boot(app)
        return app
    }

    private static func injectTestablePostgreSQL(_ services: inout Services) {
        let postgresqlConfig = PostgreSQLDatabaseConfig(
            hostname: "localhost",
            port: 5432,
            username: "skolvan",
            database: "testdungeon",
            password: nil,
            transport: .cleartext
        )
        let postgresql = PostgreSQLDatabase(config: postgresqlConfig)
        var databases = DatabasesConfig()
        databases.add(database: postgresql, as: .psql)
        services.register(databases)
    }
}
