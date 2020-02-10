//
//  CampaignControllerTests.swift
//  AppTests
//
//  Created by vorona.vyacheslav on 2020/02/04.
//

@ testable import App
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
        let email = "spiderman@email.com"
        let password = "spiderPass00"
        
        let token = try User.saveAndAuthorize(
            email: email,
            password: password,
            firstName: "First",
            lastName: "Last",
            username: "xXxSpiderManxXx777",
            on: conn
        )
        let existingUser = try token.user.get(on: conn).wait()
        
        let name = "Glorious adventure 3"
        let accessibilityInt = CampaignAccessibilityType.Private.rawValue
        let campaignContent = CampaignContent(name: name, hostId: existingUser.id, accessibilityInt: accessibilityInt)
        
        let response = try createCall(with: campaignContent, token: token)
        XCTAssertEqual(response.http.status, .ok)
        
        let responseBody = try response.content.decode(Campaign.self).wait()
        XCTAssertNotNil(responseBody.id)
        XCTAssertEqual(responseBody.name, name)
        XCTAssertEqual(responseBody.hostId, existingUser.id)
        XCTAssertLessThan(responseBody.startDate!, Date())
        XCTAssertEqual(responseBody.accessibilityInt, accessibilityInt)
    }
    
    func testCreation_unauthorized() throws {
        let campaignContent = CampaignContent(
            name: "Glorious adventure 4",
            hostId: 1,
            accessibilityInt: CampaignAccessibilityType.Private.rawValue
        )
        
        let response = try createCall(with: campaignContent)
        XCTAssertEqual(response.http.status, .unauthorized)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "User has not been authenticated.")
    }
    
    func testCreation_authorized_invalidContent() throws {
        let email = "spiderman@email.com"
        let password = "spiderPass00"
        
        let token = try User.saveAndAuthorize(
            email: email,
            password: password,
            firstName: "First",
            lastName: "Last",
            username: "xXxSpiderManxXx777",
            on: conn
        )
        let existingUser = try token.user.get(on: conn).wait()
        
        let campaignContent = CampaignContent(name: "&&%#($#0#)0  ", hostId: existingUser.id, accessibilityInt: 888)
        
        let response = try createCall(with: campaignContent, token: token)
        XCTAssertEqual(response.http.status, .badRequest)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        let reason = "'name' contains an invalid character: '&' (allowed: whitespace, A-Z, a-z, 0-9) "
        + "and 'name' should contain characters from: (A-Z, a-z) and 'name' is not nil, "
        + "'accessibilityInt' is greater than 1 and 'accessibilityInt' is not nil"
        XCTAssertEqual(errorContent.reason, reason)
    }
    
    // MARK: - Get tests
    
    private func getCall(by id: Campaign.ID) throws -> Response {
        var pathComponents = DungeonRoutes.Campaign.base.pathCompontent.convertToPathComponents()
        pathComponents.append(PathComponent.constant(String(id)))
        return try app.get(pathComponents, body: Application.Empty.instance)
    }
    
    func testGet_existingCampaign() throws {
        let name = "Tentacle clash XII"
        let hostId = 234
        let accessibilityInt = CampaignAccessibilityType.Public.rawValue
        
        let campaign = try Campaign.save(name: name, hostId: hostId, accessibilityInt: accessibilityInt, conn: conn)
        XCTAssertNotNil(campaign.id)
        
        let response = try getCall(by: campaign.id!)
        XCTAssertEqual(response.http.status, .ok)

        let responseBody = try response.content.decode(Campaign.self).wait()
        XCTAssertEqual(responseBody.id, campaign.id)
        XCTAssertEqual(responseBody.name, name)
        XCTAssertEqual(responseBody.hostId, hostId)
        XCTAssertLessThan(responseBody.startDate!, Date())
        XCTAssertEqual(responseBody.accessibilityInt, accessibilityInt)
    }
}
