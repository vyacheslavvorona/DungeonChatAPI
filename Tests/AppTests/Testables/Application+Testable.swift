//
//  Application+Testable.swift
//  AppTests
//
//  Created by Vorona Vyacheslav on 1/13/20.
//

@ testable import App
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

extension Application {
    
    private func request<T: Content>(_ path: String, method: HTTPMethod, headers: HTTPHeaders, body: T?) throws -> Response {
        let responder = try make(Responder.self)
        let httpRequest = HTTPRequest(method: method, url: URL(string: path)!, headers: headers)
        let request = Request(http: httpRequest, using: self)
        if let body = body {
            try request.content.encode(body)
        }
        return try responder.respond(to: request).wait()
    }
    
    func get<T: Content>(_ path: String, headers: HTTPHeaders = HTTPHeaders(), body: T?) throws -> Response {
        try request(path, method: .GET, headers: headers, body: body)
    }
    
    func post<T: Content>(_ path: String, headers: HTTPHeaders = HTTPHeaders(), body: T?) throws -> Response {
        try request(path, method: .POST, headers: headers, body: body)
    }
    
    func put<T: Content>(_ path: String, headers: HTTPHeaders = HTTPHeaders(), body: T?) throws -> Response {
        try request(path, method: .PUT, headers: headers, body: body)
    }
    
    func delete<T: Content>(_ path: String, headers: HTTPHeaders = HTTPHeaders(), body: T?) throws -> Response {
        try request(path, method: .DELETE, headers: headers, body: body)
    }
    
    // Using PathComponents
    
    func get<T: Content>(_ pathComponents: [PathComponent], headers: HTTPHeaders = HTTPHeaders(), body: T?) throws -> Response {
        try get(pathComponents.readable, headers: headers, body: body)
    }
    
    func post<T: Content>(_ pathComponents: [PathComponent], headers: HTTPHeaders = HTTPHeaders(), body: T?) throws -> Response {
        try post(pathComponents.readable, headers: headers, body: body)
    }
    
    func put<T: Content>(_ pathComponents: [PathComponent], headers: HTTPHeaders = HTTPHeaders(), body: T?) throws -> Response {
        try put(pathComponents.readable, headers: headers, body: body)
    }
    
    func delete<T: Content>(_ pathComponents: [PathComponent], headers: HTTPHeaders = HTTPHeaders(), body: T?) throws -> Response {
        try delete(pathComponents.readable, headers: headers, body: body)
    }
}

extension Application {
    
    struct Empty: Content {
       static let instance: Empty? = nil
    }
}
