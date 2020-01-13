//
//  Config.swift
//  App
//
//  Created by vorona.vyacheslav on 2020/01/10.
//

import Vapor
import FluentPostgreSQL

enum DungeonConfig {

    static func postgreSQLConfig(for env: Environment) -> PostgreSQLDatabaseConfig {
        switch env {
        case .development:
            return PostgreSQLDatabaseConfig(
                hostname: "localhost",
                port: 5432,
                username: "skolvan",
                database: "mydungeon",
                password: nil,
                transport: .cleartext
            )
        case .testing:
            return PostgreSQLDatabaseConfig(
                hostname: "localhost",
                port: 5432,
                username: "skolvan",
                database: "testdungeon",
                password: nil,
                transport: .cleartext
            )
        case .production:
            return PostgreSQLDatabaseConfig(
                hostname: "localhost",
                port: 5432,
                username: "skolvan",
                database: "mydungeon",
                password: nil,
                transport: .cleartext
            )
        default:
            return PostgreSQLDatabaseConfig(
                hostname: "localhost",
                port: 5432,
                username: "skolvan",
                database: "mydungeon",
                password: nil,
                transport: .cleartext
            )
        }
    }
}


