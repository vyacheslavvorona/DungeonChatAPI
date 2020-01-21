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
    
    // MARK: - Registration tests
    
    private func registerUserCall(with requestBody: User) throws -> Response {
        let pathComponents = (DungeonRoutes.User.base + DungeonRoutes.User.register).convertToPathComponents()
        return try app.post(pathComponents, body: requestBody)
    }

    func testUserRegistration_onlyEmailAndPassword() throws {
        let email = "testuser@mail.com"
        
        let requestBody = User.ut_init(email: email, password: "somePassword123")
        let response = try registerUserCall(with: requestBody)
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
    
    func testUserRegistration_allParameters() throws {
        let email = "testuser@mail.com"
        let firstName = "Logen"
        let lastName = "Bloodynine"
        let username = "Ninefingers"
        
        let requestBody = User.ut_init(email: email, password: "somePassword123")
        requestBody.firstName = firstName
        requestBody.lastName = lastName
        requestBody.username = username
        let response = try registerUserCall(with: requestBody)
        XCTAssertEqual(response.http.status, .ok)
        
        let responseBody = try response.content.decode(UserContent.self).wait()
        XCTAssertNotEqual(responseBody.id, nil)
        XCTAssertEqual(responseBody.email, email)
        // Not sure how it is going to be later, but for now we only
        // accept email and password during the registration process
        XCTAssertEqual(responseBody.firstName, nil)
        XCTAssertEqual(responseBody.lastName, nil)
        XCTAssertEqual(responseBody.username, nil)
        guard let registrationDate = responseBody.registrationDate else {
            XCTFail("No regisrationDate")
            return
        }
        XCTAssertLessThan(registrationDate, Date())
    }
    
    // Validation itself is checked by another test,
    // so we only need to check the content is validated at all
    func testUserRegistration_invalidContent() throws {
        let email = "some random string 602*&''"
        
        let requestBody = User.ut_init(email: email, password: "somePassword123")
        let response = try registerUserCall(with: requestBody)
        XCTAssertEqual(response.http.status, .badRequest)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "'email' is not a valid email address")
    }
    
    func testUserRegistration_existingEmail() throws {
        let email = "existing@user.net"
        
        try User.save(email: email, password: "l0l0l", on: conn)
        
        let requestBody = User.ut_init(email: email, password: "somePassword123")
        let response = try registerUserCall(with: requestBody)
        XCTAssertEqual(response.http.status, .badRequest)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "A User with this email already exists")
    }
}
