//
//  CampaignTests.swift
//  AppTests
//
//  Created by Vorona Vyacheslav on 1/11/20.
//

import Foundation
@ testable import App
import XCTest
import DungeonChatCore
import Vapor
import FluentPostgreSQL

final class CampaignTests: XCTestCase {

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

    // MARK: - Initialization
    
    func testInitFromContent_noName() throws {
        XCTAssertThrowsError(try Campaign(CampaignContent(), hostId: 123)) { error in
            guard case let DungeonError.missingContent(message) = error else {
                XCTFail("Wrong error type")
                return
            }
            XCTAssertEqual(message, "Campaign name is missing")
        }
    }

    func testContentInit() {
        guard let accessibilityInt = CampaignAccessibilityType.allCases.last?.rawValue else {
            XCTFail("No Campaign Accessibility Types")
            return
        }
        let content = CampaignContent(name: "Campaign Name 3", accessibilityInt: accessibilityInt)
        XCTAssertNoThrow(try Campaign(content, hostId: 123))
        let campaign = try? Campaign(content, hostId: 123)
        XCTAssert(campaign?.accessibilityInt == accessibilityInt)
    }

    // MARK: - Validation

    func testCompleteModel() throws {
        let campaign = Campaign(name: "My Campaign 9000", hostId: 99)
        campaign.accessibilityInt = 1
        try campaign.validate()
    }

    func testMinimalModel() throws {
        try Campaign(name: "My Campaign 9000", hostId: 99).validate()
    }

    func testInvalidId() throws {
        let campaign = Campaign(name: "My Campaign 9000", hostId: 99)
        campaign.id = 0
        XCTAssertThrowsError(try campaign.validate())
        campaign.id = -25
        XCTAssertThrowsError(try campaign.validate())
    }

    func testInvalidName() throws {
        XCTAssertThrowsError(try Campaign(name: "", hostId: 99).validate())
        XCTAssertThrowsError(try Campaign(name: " ", hostId: 99).validate())
        XCTAssertThrowsError(try Campaign(name: "My Campaign 9000!!", hostId: 99).validate())
        XCTAssertThrowsError(try Campaign(name: "1 2 3", hostId: 99).validate())
    }

    func testInvalidHostId() throws {
        let campaign = Campaign(name: "My Campaign 9000", hostId: 99)
        campaign.hostId = 0
        XCTAssertThrowsError(try campaign.validate())
        campaign.hostId = -33
        XCTAssertThrowsError(try campaign.validate())
    }

    func testInvalidStartDate() throws {
        let campaign = Campaign(name: "My Campaign 9000", hostId: 99)
        campaign.ut_setStartDate(Date().addingTimeInterval(500))
        XCTAssertThrowsError(try campaign.validate())
    }

    func testCampaignAccessibilityTypeCases() throws {
        let campaign = Campaign(name: "My Campaign 9000", hostId: 99)
        try CampaignAccessibilityType.allCases.forEach { type in
            campaign.accessibilityInt = type.rawValue
            try campaign.validate()
        }
    }

    func testInvalidAccessibilityInt() throws {
        let campaign = Campaign(name: "My Campaign 9000", hostId: 99)
        campaign.accessibilityInt = -2
        XCTAssertThrowsError(try campaign.validate())
        campaign.accessibilityInt = CampaignAccessibilityType.allCases.count // non existing case
        XCTAssertThrowsError(try campaign.validate())
    }

    func testUpdateFromContentWithValidHostId() throws {
        let newHost = try User.save(email: "host@email.com", password: "somepass", on: conn)
        XCTAssertNotNil(newHost.id)

        let newName = "New name"
        let newAccessibilityInt = 1
        let campaign = Campaign(name: "Test Campaign 3", hostId: 12)
        let content = CampaignContent(name: newName, hostId: newHost.id, accessibilityInt: newAccessibilityInt)
        XCTAssert(campaign.name != newName)
        XCTAssert(campaign.accessibilityInt != newAccessibilityInt)
        XCTAssert(campaign.hostId != newHost.id)

        let updated = try campaign.update(from: content, on: conn).wait()
        XCTAssert(updated.name == newName)
        XCTAssert(updated.accessibilityInt == newAccessibilityInt)
        XCTAssert(updated.hostId == newHost.id)
    }

    func testUpdateFromContentWithInvalidHostId() throws {
        let newName = "New name"
        let newAccessibilityInt = 1
        let newHostId = 800
        let campaign = Campaign(name: "Test Campaign 4", hostId: 13)
        let content = CampaignContent(name: newName, hostId: newHostId, accessibilityInt: newAccessibilityInt)
        XCTAssert(campaign.name != newName)
        XCTAssert(campaign.accessibilityInt != newAccessibilityInt)
        XCTAssert(campaign.hostId != newHostId)

        XCTAssertThrowsError(try campaign.update(from: content, on: conn).wait())
    }
    
    func testHostGetter() throws {
        let user = try User.save(
            email: "campaign@host.com",
            password: "hostpass000",
            on: conn
        )
        XCTAssertNotNil(user.id)
        
        let campaign = try Campaign.save(
            name: "Hosted Campaign",
            hostId: user.id!,
            accessibilityInt: 1,
            conn: conn
        )
        
        let host = try campaign.host.get(on: conn).wait()
        XCTAssertEqual(host.id, user.id)
        XCTAssertEqual(host.email, user.email)
    }
    
    func testParticipantsGetter_exist() throws {
        let user = try User.save(
            email: "campaign1@host.com",
            password: "hostpass000",
            on: conn
        )
        
        let campaign = try Campaign.save(
            name: "Campaign to participate",
            hostId: user.id!,
            accessibilityInt: 1,
            conn: conn
        )
        XCTAssertNotNil(campaign.id)
        
        let participant1 = try User.save(
            email: "participant1@email.com",
            password: "pass111",
            on: conn
        )
        _ = campaign.participants.attach(participant1, on: conn)
        
        let participant2 = try User.save(
            email: "participant2@email.com",
            password: "pass111",
            on: conn
        )
        _ = campaign.participants.attach(participant2, on: conn)
        
        let participants = try campaign.participants.query(on: conn).all().wait()
        XCTAssertEqual(participants.count, 2)
        XCTAssert(participants.contains(where: { $0.id! == participant1.id! }))
        XCTAssert(participants.contains(where: { $0.email == participant1.email }))
        XCTAssert(participants.contains(where: { $0.id! == participant2.id! }))
        XCTAssert(participants.contains(where: { $0.email == participant2.email }))
        
        let participatedCampaigns1 = try participant1.participatedCampaigns.query(on: conn).all().wait()
        XCTAssertEqual(participatedCampaigns1.count, 1)
        XCTAssertEqual(participatedCampaigns1.first?.id, campaign.id)
        XCTAssertEqual(participatedCampaigns1.first?.name, campaign.name)
        
        let participatedCampaigns2 = try participant2.participatedCampaigns.query(on: conn).all().wait()
        XCTAssertEqual(participatedCampaigns2.count, 1)
        XCTAssertEqual(participatedCampaigns2.first?.id, campaign.id)
        XCTAssertEqual(participatedCampaigns2.first?.name, campaign.name)
    }
    
    func testParticipantsGetter_empty() throws {
        let user = try User.save(
            email: "campaign2@host.com",
            password: "hostpass000",
            on: conn
        )
        
        let campaign = try Campaign.save(
            name: "Campaign to participate",
            hostId: user.id!,
            accessibilityInt: 1,
            conn: conn
        )
        
        let participants = try campaign.participants.query(on: conn).all().wait()
        XCTAssert(participants.isEmpty)
    }
}
