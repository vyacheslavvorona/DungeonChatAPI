//
//  CampaignContentTests.swift
//  AppTests
//
//  Created by Vorona Vyacheslav on 1/11/20.
//

import Foundation
import App
import XCTest
import DungeonChatCore

final class CampaignContentTests: XCTestCase {

    func testCompleteContent() throws {
        try CampaignContent(
            id: 71,
            name: "Bizarre Adventure 3",
            hostId: 12,
            startDate: Date(),
            accessibilityInt: 1
        ).validate()
    }

    func testNilContent() throws {
        try CampaignContent().validate()
    }

    func testInvalidId() throws {
        XCTAssertThrowsError(try CampaignContent(id: 0).validate())
        XCTAssertThrowsError(try CampaignContent(id: -3).validate())
    }

    func testInvalidName() throws {
        XCTAssertThrowsError(try CampaignContent(name: "").validate())
        XCTAssertThrowsError(try CampaignContent(name: " ").validate())
        XCTAssertThrowsError(try CampaignContent(name: "Bad Name &%").validate())
        XCTAssertThrowsError(try CampaignContent(name: "1 2 3").validate())
    }

    func testInvalidHostId() throws {
        XCTAssertThrowsError(try CampaignContent(hostId: 0).validate())
        XCTAssertThrowsError(try CampaignContent(hostId: -12).validate())
    }

    func testInvalidStartDate() throws {
        XCTAssertThrowsError(try CampaignContent(startDate: Date().addingTimeInterval(500)).validate())
    }

    func testCampaignAccessibilityTypeCases() throws {
        try CampaignAccessibilityType.allCases.forEach {
            try CampaignContent(accessibilityInt: $0.rawValue).validate()
        }
    }

    func testInvalidAccessibilityInt() throws {
        XCTAssertThrowsError(try CampaignContent(accessibilityInt: -2).validate())
        let nonexistingCase = CampaignAccessibilityType.allCases.count
        XCTAssertThrowsError(try CampaignContent(accessibilityInt: nonexistingCase).validate())
    }
}
