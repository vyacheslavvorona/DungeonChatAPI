//
//  CampaignControllerTests.swift
//  AppTests
//
//  Created by vorona.vyacheslav on 2020/02/04.
//

import App
import XCTest
import Validation
import DungeonChatCore
import Vapor
import FluentPostgreSQL

final class CampaignControllerTests: XCTestCase {
    
    var app: Application!
    var conn: PostgreSQLConnection!

    override func setUp() {
        super.setUp()

        try! Application.resetDatabase()

        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }

    override func tearDown() {
        super.tearDown()

        conn.close()
    }
    
    // MARK: - Creation tests
    
    private func createCall(with requestBody: CampaignContent, token: AuthToken? = nil) throws -> Response {
        let pathComponents = DungeonRoutes.Campaign.base.pathCompontent.convertToPathComponents()
        var headers = HTTPHeaders()
        if let token = token {
            headers.add(name: "Authorization", value: token.headerValue)
        }
        return try app.post(pathComponents, headers: headers, body: requestBody)
    }
    
    func testCreation_authorized_fullContent() throws {
//        let email = "spiderman@email.com"
//        let password = "spiderPass00"
//        
//        let token = try User.saveAndAuthorize(
//            email: email,
//            password: password,
//            firstName: "First",
//            lastName: "Last",
//            username: "xXxSpiderManxXx777",
//            on: conn
//        )
//        let existingUser = try token.user.get(on: conn).wait()
    }
}
