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
    
    private func registerCall(with requestBody: User) throws -> Response {
        let pathComponents = (DungeonRoutes.User.base + DungeonRoutes.User.register).convertToPathComponents()
        return try app.post(pathComponents, body: requestBody)
    }

    func testRegistration_onlyEmailAndPassword() throws {
        let email = "testuser@mail.com"
        
        let requestBody = User.ut_init(email: email, password: "somePassword123")
        let response = try registerCall(with: requestBody)
        XCTAssertEqual(response.http.status, .ok)
        
        let responseBody = try response.content.decode(UserContent.self).wait()
        XCTAssertNotNil(responseBody.id)
        XCTAssertEqual(responseBody.email, email)
        XCTAssertNil(responseBody.firstName)
        XCTAssertNil(responseBody.lastName)
        XCTAssertNil(responseBody.username)
        XCTAssertLessThan(responseBody.registrationDate!, Date())
    }
    
    func testRegistration_allParameters() throws {
        let email = "testuser@mail.com"
        let firstName = "Logen"
        let lastName = "Bloodynine"
        let username = "Ninefingers9"
        
        let requestBody = User.ut_init(email: email, password: "somePassword123")
        requestBody.firstName = firstName
        requestBody.lastName = lastName
        requestBody.username = username
        let response = try registerCall(with: requestBody)
        XCTAssertEqual(response.http.status, .ok)
        
        let responseBody = try response.content.decode(UserContent.self).wait()
        XCTAssertNotNil(responseBody.id)
        XCTAssertEqual(responseBody.email, email)
        // Not sure how it is going to be later, but for now we only
        // accept email and password during the registration process
        XCTAssertNil(responseBody.firstName)
        XCTAssertNil(responseBody.lastName)
        XCTAssertNil(responseBody.username)
        XCTAssertLessThan(responseBody.registrationDate!, Date())
    }
    
    // Validation itself is checked by another test,
    // so we only need to check the content is validated at all
    func testRegistration_invalidContent() throws {
        let email = "some random string 602*&''"
        
        let requestBody = User.ut_init(email: email, password: "somePassword123")
        let response = try registerCall(with: requestBody)
        XCTAssertEqual(response.http.status, .badRequest)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "'email' is not a valid email address")
    }
    
    func testRegistration_existingEmail() throws {
        let email = "existing@user.net"
        
        try User.save(email: email, password: "l0l0l", on: conn)
        
        let requestBody = User.ut_init(email: email, password: "somePassword123")
        let response = try registerCall(with: requestBody)
        XCTAssertEqual(response.http.status, .badRequest)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "A User with this email already exists")
    }
    
    // MARK: - Login tests
    
    private func loginCall(with requestBody: User) throws -> Response {
        let pathComponents = (DungeonRoutes.User.base + DungeonRoutes.User.login).convertToPathComponents()
        return try app.post(pathComponents, body: requestBody)
    }
    
    func testLogin_existingEmail_correctPassword() throws {
        let email = "batman@email.com"
        let password = "batPass00"
        
        let existingUser = try User.save(email: email, password: password, on: conn)
        
        let requestBody = User.ut_init(email: email, password: password)
        let response = try loginCall(with: requestBody)
        XCTAssertEqual(response.http.status, .ok)
        
        let responseBody = try response.content.decode(AuthToken.self).wait()
        XCTAssertNotNil(responseBody.id)
        XCTAssertNotNil(responseBody.userId)
        XCTAssertEqual(responseBody.userId, existingUser.id)
        XCTAssertLessThan(responseBody.authDate, Date())
    }
    
    func testLogin_existingEmail_correctPassword_extraParameters() throws {
        let email = "batman@email.com"
        let password = "batPass00"
        
        let existingUser = try User.save(email: email, password: password, on: conn)
        
        let requestBody = User.ut_init(email: email, password: password)
        requestBody.firstName = "Bat"
        requestBody.lastName = "Man"
        requestBody.username = "Batman"
        let response = try loginCall(with: requestBody)
        XCTAssertEqual(response.http.status, .ok)
        
        let responseBody = try response.content.decode(AuthToken.self).wait()
        XCTAssertNotNil(responseBody.id)
        XCTAssertNotNil(responseBody.userId)
        XCTAssertEqual(responseBody.userId, existingUser.id)
        XCTAssertLessThan(responseBody.authDate, Date())
        
        guard let userId = existingUser.id,
            let savedUser = try User.find(userId, on: conn).wait() else {
            XCTFail("No user in database")
            return
        }
        
        XCTAssertNil(savedUser.firstName)
        XCTAssertNil(savedUser.lastName)
        XCTAssertNil(savedUser.username)
    }
    
    func testLogin_invalidEmail() throws {
        let requestBody = User.ut_init(email: "wrong-email-81212", password: "somepass123")
        let response = try loginCall(with: requestBody)
        XCTAssertEqual(response.http.status, .badRequest)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "Wrong email format")
    }
    
    func testLogin_emailNotExist() throws {
        let requestBody = User.ut_init(email: "batman1@email.com", password: "batPass01")
        let response = try loginCall(with: requestBody)
        XCTAssertEqual(response.http.status, .notFound)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "No User with specified email")
    }
    
    func testLogin_existingEmail_incorrectPassword() throws {
        let email = "batman@email.com"
        let password = "batPass00"
        
        try User.save(email: email, password: "wronggg00", on: conn)
        
        let requestBody = User.ut_init(email: email, password: password)
        let response = try loginCall(with: requestBody)
        XCTAssertEqual(response.http.status, .unauthorized)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "Wrong password")
    }
    
    // MARK: - Get tests
    
    private func getCall(by id: User.ID) throws -> Response {
        var pathComponents = DungeonRoutes.User.base.pathCompontent.convertToPathComponents()
        pathComponents.append(PathComponent.constant(String(id)))
        return try app.get(pathComponents, body: Application.Empty.instance)
    }
    
    func testGet_existingUser() throws {
        let email = "superman@email.com"
        let password = "superPass1"
        
        let existingUser = try User.save(email: email, password: password, on: conn)
        
        guard let userId = existingUser.id else {
            XCTFail("No user id")
            return
        }
        
        let response = try getCall(by: userId)
        XCTAssertEqual(response.http.status, .ok)

        let responseBody = try response.content.decode(UserContent.self).wait()
        XCTAssertEqual(responseBody.id, userId)
        XCTAssertNil(responseBody.firstName)
        XCTAssertNil(responseBody.lastName)
        XCTAssertNil(responseBody.username)
        XCTAssertLessThan(responseBody.registrationDate!, Date())
    }
}
