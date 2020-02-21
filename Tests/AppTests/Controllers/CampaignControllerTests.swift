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
    
    func testCreation_authorized_noName() throws {
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
        
        let campaignContent = CampaignContent()
        
        let response = try createCall(with: campaignContent, token: token)
        XCTAssertEqual(response.http.status, .badRequest)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        let reason = "Campaign name is missing"
        XCTAssertEqual(errorContent.reason, reason)
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
    
    func testGet_nonExistingCampaign() throws {
        let response = try getCall(by: 999)
        XCTAssertEqual(response.http.status, .notFound)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "No Campaign with specified id")
    }
    
    // MARK: - Update tests
    
    private func updateCall(id: Campaign.ID, with requestBody: CampaignContent, token: AuthToken? = nil) throws -> Response {
        var pathComponents = DungeonRoutes.Campaign.base.pathCompontent.convertToPathComponents()
        pathComponents.append(PathComponent.constant(String(id)))
        var headers = HTTPHeaders()
        if let token = token {
            headers.add(name: "Authorization", value: token.headerValue)
        }
        return try app.put(pathComponents, headers: headers, body: requestBody)
    }
    
    func testUpdate_existingCampaign_fullContent_authorized() throws {
        let email = "spiderman1@email.com"
        let password = "spiderPass0da0"
        
        let token = try User.saveAndAuthorize(
            email: email,
            password: password,
            firstName: "First",
            lastName: "Last",
            username: "xXxSpiderManxXx777",
            on: conn
        )
        let existingUser = try token.user.get(on: conn).wait()
        
        let newHost = try User.save(
            email: "some@email.com",
            password: "somepass1",
            on: conn
        )
        XCTAssertNotNil(newHost.id)
        
        let campaign = try Campaign.save(
            name: "Some campaign 2",
            hostId: existingUser.id!,
            accessibilityInt: CampaignAccessibilityType.Private.rawValue,
            conn: conn
        )
        XCTAssertNotNil(campaign.id)
        
        let newName = "Some other Campaign"
        let updateContent = CampaignContent(
            id: 782,
            name: newName,
            hostId: newHost.id!,
            startDate: Date().addingTimeInterval(-800),
            accessibilityInt: CampaignAccessibilityType.Public.rawValue
        )
        
        let response = try updateCall(id: campaign.id!, with: updateContent, token: token)
        XCTAssertEqual(response.http.status, .ok)
        
        let responseBody = try response.content.decode(Campaign.self).wait()
        XCTAssertEqual(responseBody.id, campaign.id)
        XCTAssertEqual(responseBody.name, newName)
        XCTAssertEqual(responseBody.hostId, newHost.id)
        XCTAssert(responseBody.startDate! =~~ campaign.startDate!)
        XCTAssertEqual(responseBody.accessibilityInt, CampaignAccessibilityType.Public.rawValue)
    }
    
    func testUpdate_existingCampaign_oldHost_authorized() throws {
        let email = "spiderman2@email.com"
        let password = "spiderPass0da0"
        
        let token = try User.saveAndAuthorize(
            email: email,
            password: password,
            firstName: "First",
            lastName: "Last",
            username: "xXxSpiderManxXx777",
            on: conn
        )
        let existingUser = try token.user.get(on: conn).wait()
        XCTAssertNotNil(existingUser.id)
        
        let campaign = try Campaign.save(
            name: "Some campaign 2",
            hostId: existingUser.id!,
            accessibilityInt: CampaignAccessibilityType.Private.rawValue,
            conn: conn
        )
        XCTAssertNotNil(campaign.id)
        
        let newName = "Some other Campaign"
        let updateContent = CampaignContent(
            id: 783,
            name: newName,
            startDate: Date().addingTimeInterval(-800),
            accessibilityInt: CampaignAccessibilityType.Public.rawValue
        )
        
        let response = try updateCall(id: campaign.id!, with: updateContent, token: token)
        XCTAssertEqual(response.http.status, .ok)
        
        let responseBody = try response.content.decode(Campaign.self).wait()
        XCTAssertEqual(responseBody.id, campaign.id)
        XCTAssertEqual(responseBody.name, newName)
        XCTAssertEqual(responseBody.hostId, existingUser.id)
        XCTAssert(responseBody.startDate! =~~ campaign.startDate!)
        XCTAssertEqual(responseBody.accessibilityInt, CampaignAccessibilityType.Public.rawValue)
    }
    
    func testUpdate_existingCampaign_emptyContent_authorized() throws {
        let email = "spiderman3@email.com"
        let password = "spiderPass0da0"
        
        let token = try User.saveAndAuthorize(
            email: email,
            password: password,
            firstName: "First",
            lastName: "Last",
            username: "xXxSpiderManxXx777",
            on: conn
        )
        
        let response = try updateCall(id: 456, with: CampaignContent(), token: token)
        XCTAssertEqual(response.http.status, .badRequest)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "Request does not contain updatable data")
    }
    
    func testUpdate_nonExistingCampaign_authorized() throws {
        let email = "spiderman3@email.com"
        let password = "spiderPass0da0"
        
        let token = try User.saveAndAuthorize(
            email: email,
            password: password,
            firstName: "First",
            lastName: "Last",
            username: "xXxSpiderManxXx777",
            on: conn
        )
        
        let updateContent = CampaignContent(
            name: "Some new name",
            accessibilityInt: CampaignAccessibilityType.Public.rawValue
        )
        
        let response = try updateCall(id: 848, with: updateContent, token: token)
        XCTAssertEqual(response.http.status, .notFound)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "No Campaign with specified id")
    }
    
    func testUpdate_notToken() throws {
        let updateContent = CampaignContent(
            name: "Some new name",
            accessibilityInt: CampaignAccessibilityType.Public.rawValue
        )
        
        let response = try updateCall(id: 848, with: updateContent)
        XCTAssertEqual(response.http.status, .unauthorized)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "User has not been authenticated.")
    }
    
    func testUpdate_wrongToken() throws {
        let email = "spiderman4@email.com"
        let password = "spiderPass0da0"
        let wrongTokenString = "zBzpirY2HYQK3HI9g25NSt7qtVUI0z7EIhxEsrMA/04="
        
        let token = try User.saveAndAuthorize(
            email: email,
            password: password,
            firstName: "First",
            lastName: "Last",
            username: "xXxSpiderManxXx777",
            on: conn
        )
        let existingUser = try token.user.get(on: conn).wait()
        
        try Campaign.save(
            name: "My Great Campaign",
            hostId: existingUser.id!,
            accessibilityInt: CampaignAccessibilityType.Private.rawValue,
            conn: conn
        )
        
        let wrongToken = AuthToken(token: wrongTokenString, userId: existingUser.id!)
        XCTAssertNotEqual(token.token, wrongToken.token)
        
        let updateContent = CampaignContent(
            name: "Some new name",
            accessibilityInt: CampaignAccessibilityType.Public.rawValue
        )
        
        let response = try updateCall(id: 848, with: updateContent)
        XCTAssertEqual(response.http.status, .unauthorized)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "User has not been authenticated.")
    }
    
    // MARK: - Delete tests
    
    private func deleteCall(id: Campaign.ID, token: AuthToken? = nil) throws -> Response {
        var pathComponents = DungeonRoutes.Campaign.base.pathCompontent.convertToPathComponents()
        pathComponents.append(PathComponent.constant(String(id)))
        var headers = HTTPHeaders()
        if let token = token {
            headers.add(name: "Authorization", value: token.headerValue)
        }
        return try app.delete(pathComponents, headers: headers, body: Application.Empty.instance)
    }
    
    func testDelete_existingCampaign_host_authorized() throws {
        let email = "spiderman5@email.com"
        let password = "spiderPass0da0"
        
        let token = try User.saveAndAuthorize(
            email: email,
            password: password,
            firstName: "First",
            lastName: "Last",
            username: "xXxSpiderManxXx777",
            on: conn
        )
        let existingUser = try token.user.get(on: conn).wait()
        
        let campaign = try Campaign.save(
            name: "Campaign to Delete 1",
            hostId: existingUser.id!,
            accessibilityInt: CampaignAccessibilityType.Private.rawValue,
            conn: conn
        )
        let campaignId = campaign.id
        XCTAssertNotNil(campaignId)
        
        let response = try deleteCall(id: campaignId!, token: token)
        XCTAssertEqual(response.http.status, .noContent)
        
        let deletedCampaign = try Campaign.find(campaignId!, on: conn).wait()
        XCTAssertNil(deletedCampaign)
    }
    
    func testDelete_nonExistingCampaign_host_authorized() throws {
        let email = "spiderman6@email.com"
        let password = "spiderPass0da0"
        
        let token = try User.saveAndAuthorize(
            email: email,
            password: password,
            firstName: "First",
            lastName: "Last",
            username: "xXxSpiderManxXx777",
            on: conn
        )
        
        let response = try deleteCall(id: 156, token: token)
        XCTAssertEqual(response.http.status, .notFound)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "No Campaign with specified id")
    }
    
    func testDelete_existingCampaign_notHost_authorized() throws {
        let email = "spiderman7@email.com"
        let password = "spiderPass0da0"
        
        let token = try User.saveAndAuthorize(
            email: email,
            password: password,
            firstName: "First",
            lastName: "Last",
            username: "xXxSpiderManxXx777",
            on: conn
        )
        
        let campaign = try Campaign.save(
            name: "Campaign to Delete 3",
            hostId: 123,
            accessibilityInt: CampaignAccessibilityType.Private.rawValue,
            conn: conn
        )
        let campaignId = campaign.id
        XCTAssertNotNil(campaignId)
        
        let response = try deleteCall(id: campaignId!, token: token)
        XCTAssertEqual(response.http.status, .forbidden)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "User is not able to delete specified Campaign")
    }
    
    func testDelete_existingCampaign_host_unauthorized() throws {
        let email = "spiderman8@email.com"
        let password = "spiderPass0da0"
        
        let existingUser = try User.save(email: email, password: password, on: conn)
        
        let campaign = try Campaign.save(
            name: "Campaign to Delete 4",
            hostId: existingUser.id!,
            accessibilityInt: CampaignAccessibilityType.Private.rawValue,
            conn: conn
        )
        let campaignId = campaign.id
        XCTAssertNotNil(campaignId)
        
        let response = try deleteCall(id: campaignId!, token: nil)
        XCTAssertEqual(response.http.status, .unauthorized)
        
        let errorContent = try response.content.decode(ErrorMiddlewareContent.self).wait()
        XCTAssert(errorContent.error)
        XCTAssertEqual(errorContent.reason, "User has not been authenticated.")
    }
}
