//
//  User.swift
//  App
//
//  Created by Vorona Vyacheslav on 1/11/20.
//

@ testable import App
import XCTest
import DungeonChatCore
import Vapor
import FluentPostgreSQL

final class UserTests: XCTestCase {
    
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

    // MARK: - Validation

    func testCompleteModel() throws {
        let user = try User(email: "email@test.com", password: "lalo4ka$")
        user.id = 22
        user.firstName = "Andrey"
        user.lastName = "Govnenko"
        user.username = "Mamkoglad420"
        XCTAssertNoThrow(try user.validate())
    }

    func testMinimalModel() throws {
        XCTAssertNoThrow(try User(email: "opop@test.com", password: "qwerty").validate())
    }

    func testInitFromContent_niceContent() throws {
        let content = UserContent(email: "asd@asd.asd", password: "goodpass2")
        XCTAssertNoThrow(try User(from: content))
    }
    
    func testInitFromContent_noEmail() throws {
        let content = UserContent(password: "goodpass2")
        XCTAssertThrowsError(try User(from: content)) { error in
            guard case let DungeonError.missingContent(message) = error else {
                XCTFail("Wrong error type")
                return
            }
            XCTAssertEqual(message, "Email is missing")
        }
    }
    
    func testInitFromContent_noPassword() throws {
        let content = UserContent(email: "asd@asd.asd")
        XCTAssertThrowsError(try User(from: content)) { error in
            guard case let DungeonError.missingContent(message) = error else {
                XCTFail("Wrong error type")
                return
            }
            XCTAssertEqual(message, "Password is missing")
        }
    }
    
    func testInvalidId() throws {
        let user = try User(email: "email@test.com", password: "lalo4ka$")
        user.id = 0
        XCTAssertThrowsError(try user.validate())
        user.id = -123
        XCTAssertThrowsError(try user.validate())
    }

    func testInvalidEmail() throws {
        XCTAssertThrowsError(try User(email: "some string", password: "lalo4ka$").validate())
        XCTAssertThrowsError(try User(email: "email@test.comemail@test.com", password: "lalo4ka$").validate())
        XCTAssertThrowsError(try User(email: "", password: "lalo4ka$").validate())
        XCTAssertThrowsError(try User(email: " ", password: "lalo4ka$").validate())
        XCTAssertThrowsError(try User(email: "asd@asd.45", password: "lalo4ka$").validate())
        XCTAssertThrowsError(try User(email: "@asd.com", password: "lalo4ka$").validate())
        XCTAssertThrowsError(try User(email: "asd@.com", password: "lalo4ka$").validate())
        XCTAssertThrowsError(try User(email: "asd@asd.", password: "lalo4ka$").validate())
    }

    func testInvalidFirstName() throws {
        let user = try User(email: "email@test.com", password: "lalo4ka$")
        user.firstName = ""
        XCTAssertThrowsError(try user.validate())
        user.firstName = " "
        XCTAssertThrowsError(try user.validate())
        user.firstName = "Z"
        XCTAssertThrowsError(try user.validate())
        user.firstName = "22"
        XCTAssertThrowsError(try user.validate())
        user.firstName = "Andrey2"
        XCTAssertThrowsError(try user.validate())
        user.firstName = "Tom))"
        XCTAssertThrowsError(try user.validate())
        user.firstName = "email@test.com"
        XCTAssertThrowsError(try user.validate())
    }

    func testInvalidLastName() throws {
        let user = try User(email: "email@test.com", password: "lalo4ka$")
        user.lastName = ""
        XCTAssertThrowsError(try user.validate())
        user.lastName = "  "
        XCTAssertThrowsError(try user.validate())
        user.lastName = "A"
        XCTAssertThrowsError(try user.validate())
        user.lastName = "12"
        XCTAssertThrowsError(try user.validate())
        user.lastName = "Huev00"
        XCTAssertThrowsError(try user.validate())
        user.lastName = "Jackson!"
        XCTAssertThrowsError(try user.validate())
        user.lastName = "email@test.com"
        XCTAssertThrowsError(try user.validate())
    }

    func testInvalidSUsername() throws {
        let user = try User(email: "email@test.com", password: "lalo4ka$")
        user.username = ""
        XCTAssertThrowsError(try user.validate())
        user.username = "  "
        XCTAssertThrowsError(try user.validate())
        user.username = "A"
        XCTAssertThrowsError(try user.validate())
        user.username = "12"
        XCTAssertThrowsError(try user.validate())
        user.username = "NaGiBatoR!"
        XCTAssertThrowsError(try user.validate())
        user.username = "email@test.com"
        XCTAssertThrowsError(try user.validate())
    }

    func testInvalidRegistrationDate() throws {
        let user = try User(email: "email@test.com", password: "lalo4ka$")
        user.ut_setRegistrationDate(Date().addingTimeInterval(500))
        XCTAssertThrowsError(try user.validate())
    }
    
    func testHostedCampaignsGetter_exist() throws {
        let user = try User.save(
            email: "campaign@host.com",
            password: "hostpass000",
            on: conn
        )
        XCTAssertNotNil(user.id)
        
        let campaign1 = try Campaign.save(
            name: "Campaign 1",
            hostId: user.id!,
            accessibilityInt: 1,
            conn: conn
        )
        
        let campaign2 = try Campaign.save(
            name: "Campaign 2",
            hostId: user.id!,
            accessibilityInt: 1,
            conn: conn
        )
        
        let hostedCampaigns = try user.hostedCampaigns.query(on: conn).all().wait()
        XCTAssertEqual(hostedCampaigns.count, 2)
        XCTAssert(hostedCampaigns.contains(where: { $0.id! == campaign1.id! }))
        XCTAssert(hostedCampaigns.contains(where: { $0.name == campaign1.name }))
        XCTAssert(hostedCampaigns.contains(where: { $0.id! == campaign2.id! }))
        XCTAssert(hostedCampaigns.contains(where: { $0.name == campaign2.name }))
    }
    
    func testHostedCampaignsGetter_empty() throws {
        let user = try User.save(
            email: "campaign1@host.com",
            password: "hostpass000",
            on: conn
        )
        XCTAssertNotNil(user.id)
        
        let hostedCampaigns = try user.hostedCampaigns.query(on: conn).all().wait()
        XCTAssert(hostedCampaigns.isEmpty)
    }
    
    func testParticipatedCampaignsGetter_exist() throws {
        let user = try User.save(
            email: "campaign@oarticipant.com",
            password: "pass000",
            on: conn
        )
        XCTAssertNotNil(user.id)
        
        let campaign1 = try Campaign.save(
            name: "Campaign 1",
            hostId: 785,
            accessibilityInt: 1,
            conn: conn
        )
        _ = try user.participatedCampaigns.attach(campaign1, on: conn).wait()
        
        let campaign2 = try Campaign.save(
            name: "Campaign 2",
            hostId: 432,
            accessibilityInt: 1,
            conn: conn
        )
        _ = try user.participatedCampaigns.attach(campaign2, on: conn).wait()
        
        let participatedCampaigns = try user.participatedCampaigns.query(on: conn).all().wait()
        XCTAssertEqual(participatedCampaigns.count, 2)
        XCTAssert(participatedCampaigns.contains(where: { $0.id! == campaign1.id! }))
        XCTAssert(participatedCampaigns.contains(where: { $0.name == campaign1.name }))
        XCTAssert(participatedCampaigns.contains(where: { $0.id! == campaign2.id! }))
        XCTAssert(participatedCampaigns.contains(where: { $0.name == campaign2.name }))
        
        let campaign1Participants = try campaign1.participants.query(on: conn).all().wait()
        XCTAssertEqual(campaign1Participants.count, 1)
        XCTAssertEqual(campaign1Participants.first?.id, user.id)
        XCTAssertEqual(campaign1Participants.first?.email, user.email)
        
        let campaign2Participants = try campaign2.participants.query(on: conn).all().wait()
        XCTAssertEqual(campaign2Participants.count, 1)
        XCTAssertEqual(campaign2Participants.first?.id, user.id)
        XCTAssertEqual(campaign2Participants.first?.email, user.email)
    }
    
    func testParticipatedCampaignsGetter_empty() throws {
        let user = try User.save(
            email: "campaign@oarticipant.com",
            password: "pass000",
            on: conn
        )
        
        let participatedCampaigns = try user.participatedCampaigns.query(on: conn).all().wait()
        XCTAssert(participatedCampaigns.isEmpty)
    }
}
