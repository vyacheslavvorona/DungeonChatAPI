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
    static func testable(arguments: [String] = CommandLine.arguments) throws -> Application {
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        env.arguments = arguments
        try App.configure(&config, &env, &services)
        let app = try Application(config: config, environment: env, services: services)
        try App.boot(app)
        return app
    }

    static func resetDatabase() throws {
        try testable(arguments: ["vapor", "revert", "--all", "-y"]).run()
        try testable(arguments: ["vapor", "migrate", "-y"]).run()
    }
}
