//
//  CampaignTests.swift
//  AppTests
//
//  Created by Vorona Vyacheslav on 1/11/20.
//

import Foundation
import App
import XCTest
import DungeonChatCore
import Vapor
import FluentPostgreSQL

final class CampaignTests: XCTestCase {

    var app: Application!
    var conn: PostgreSQLConnection!

    override func setUp() {
        super.setUp()

        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }

    override func tearDown() {
        super.tearDown()

        conn.close()
    }

    // MARK: - Initialization

    func testInvalidContentInit() {
        XCTAssertNil(Campaign.ut_init(CampaignContent(), hostId: 123))
    }

    func testContentInit() {
        guard let accessibilityInt = CampaignAccessibilityType.allCases.last?.rawValue else {
            XCTFail("No Campaign Accessibility Types")
            return
        }
        let content = CampaignContent(name: "Campaign Name 3", accessibilityInt: accessibilityInt)
        guard let campaign = Campaign.ut_init(content, hostId: 123) else {
            XCTFail("Campaign is not created")
            return
        }
        XCTAssert(campaign.accessibilityInt == accessibilityInt)
    }

    // MARK: - Validation

    func testCompleteModel() throws {
        let campaign = Campaign.ut_init(name: "My Campaign 9000", hostId: 99)
        campaign.accessibilityInt = 1
        try campaign.validate()
    }

    func testMinimalModel() throws {
        try Campaign.ut_init(name: "My Campaign 9000", hostId: 99).validate()
    }

    func testInvalidId() throws {
        let campaign = Campaign.ut_init(name: "My Campaign 9000", hostId: 99)
        campaign.id = 0
        XCTAssertThrowsError(try campaign.validate())
        campaign.id = -25
        XCTAssertThrowsError(try campaign.validate())
    }

    func testInvalidName() throws {
        XCTAssertThrowsError(try Campaign.ut_init(name: "", hostId: 99).validate())
        XCTAssertThrowsError(try Campaign.ut_init(name: " ", hostId: 99).validate())
        XCTAssertThrowsError(try Campaign.ut_init(name: "My Campaign 9000!!", hostId: 99).validate())
        XCTAssertThrowsError(try Campaign.ut_init(name: "1 2 3", hostId: 99).validate())
    }

    func testInvalidHostId() throws {
        let campaign = Campaign.ut_init(name: "My Campaign 9000", hostId: 99)
        campaign.hostId = 0
        XCTAssertThrowsError(try campaign.validate())
        campaign.hostId = -33
        XCTAssertThrowsError(try campaign.validate())
    }

    func testInvalidStartDate() throws {
        let campaign = Campaign.ut_init(name: "My Campaign 9000", hostId: 99)
        campaign.ut_setStartDate(Date().addingTimeInterval(500))
        XCTAssertThrowsError(try campaign.validate())
    }

    func testCampaignAccessibilityTypeCases() throws {
        let campaign = Campaign.ut_init(name: "My Campaign 9000", hostId: 99)
        try CampaignAccessibilityType.allCases.forEach { type in
            campaign.accessibilityInt = type.rawValue
            try campaign.validate()
        }
    }

    func testInvalidAccessibilityInt() throws {
        let campaign = Campaign.ut_init(name: "My Campaign 9000", hostId: 99)
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
        let campaign = Campaign.ut_init(name: "Test Campaign 3", hostId: 12)
        let content = CampaignContent(name: newName, hostId: newHost.id, accessibilityInt: newAccessibilityInt)
        XCTAssert(campaign.name != newName)
        XCTAssert(campaign.accessibilityInt != newAccessibilityInt)
        XCTAssert(campaign.hostId != newHost.id)

        let updated = try campaign.ut_update(from: content, on: conn).wait()
        XCTAssert(updated.name == newName)
        XCTAssert(updated.accessibilityInt == newAccessibilityInt)
        XCTAssert(updated.hostId == newHost.id)
    }

    func testUpdateFromContentWithInvalidHostId() throws {
        let newName = "New name"
        let newAccessibilityInt = 1
        let newHostId = 800
        let campaign = Campaign.ut_init(name: "Test Campaign 4", hostId: 13)
        let content = CampaignContent(name: newName, hostId: newHostId, accessibilityInt: newAccessibilityInt)
        XCTAssert(campaign.name != newName)
        XCTAssert(campaign.accessibilityInt != newAccessibilityInt)
        XCTAssert(campaign.hostId != newHostId)

        XCTAssertThrowsError(try campaign.ut_update(from: content, on: conn).wait())
    }
}
