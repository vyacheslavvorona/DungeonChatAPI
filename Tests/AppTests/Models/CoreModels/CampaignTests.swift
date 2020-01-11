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

final class CampaignTests: XCTestCase {

    // MARK: - Initialization

    func testInvalidContentInit() {
        XCTAssert(Campaign.ut_init(CampaignContent(), hostId: 123) == nil)
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
}
