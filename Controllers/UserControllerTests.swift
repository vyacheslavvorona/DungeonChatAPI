//
//  UserControllerTests.swift
//  App
//
//  Created by vorona.vyacheslav on 2020/01/20.
//

import App
import XCTest
import Validation
import DungeonChatCore
import Vapor
import FluentPostgreSQL

final class UserControllerTests: XCTestCase {
    
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

    func testUserRegistration_onlyEmailAndPassword() throws {
        let email = "testuser@mail.com"
        
        let requestBody = User.ut_init(email: email, password: "somePassword123")
        let pathComponents = (DungeonRoutes.User.base + DungeonRoutes.User.register).convertToPathComponents()
        let response = try app.post(pathComponents, body: requestBody)
        XCTAssertEqual(response.http.status, .ok)
        
        let responseBody = try response.content.decode(UserContent.self).wait()
        XCTAssertNotEqual(responseBody.id, nil)
        XCTAssertEqual(responseBody.email, email)
        XCTAssertEqual(responseBody.firstName, nil)
        XCTAssertEqual(responseBody.lastName, nil)
        XCTAssertEqual(responseBody.username, nil)
        guard let registrationDate = responseBody.registrationDate else {
            XCTFail("No regisrationDate")
            return
        }
        XCTAssertLessThan(registrationDate, Date())
    }
}
