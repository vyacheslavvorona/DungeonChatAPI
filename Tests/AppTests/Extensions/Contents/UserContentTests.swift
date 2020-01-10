//
//  UserContentTests.swift
//  AppTests
//
//  Created by Vorona Vyacheslav on 1/11/20.
//

import Foundation
import App
import XCTest
import DungeonChatCore

final class UserContentTests: XCTestCase {

    func testCompleteContent() throws {
        let userContent = UserContent(
            id: 42,
            email: "email@test.com",
            firstName: "Ivan",
            lastName: "Petrov",
            username: "Nagibator69",
            registrationDate: Date()
        )
        try userContent.validate()
    }

    func testNilContent() throws {
        let userContent = UserContent()
        try userContent.validate()
    }

    func testInvalidId() throws {
        let userContent1 = UserContent(id: 0)
        XCTAssertThrowsError(try userContent1.validate())
        let userContent2 = UserContent(id: -3)
        XCTAssertThrowsError(try userContent2.validate())
    }

    func testInvalidEmail() throws {
        let userContent1 = UserContent(email: "email@test.comemail@test.com")
        XCTAssertThrowsError(try userContent1.validate())
        let userContent2 = UserContent(email: "")
        XCTAssertThrowsError(try userContent2.validate())
        let userContent3 = UserContent(email: "asd@asd.45")
        XCTAssertThrowsError(try userContent3.validate())
        let userContent4 = UserContent(email: "@asd.com")
        XCTAssertThrowsError(try userContent4.validate())
        let userContent5 = UserContent(email: "asd@.com")
        XCTAssertThrowsError(try userContent5.validate())
        let userContent6 = UserContent(email: "asd@asd.")
        XCTAssertThrowsError(try userContent6.validate())
    }

    func testInvalidFirstName() throws {
        let userContent1 = UserContent(firstName: "")
        XCTAssertThrowsError(try userContent1.validate())
        let userContent2 = UserContent(firstName: "Petr4")
        XCTAssertThrowsError(try userContent2.validate())
        let userContent3 = UserContent(firstName: "Oleg&")
        XCTAssertThrowsError(try userContent3.validate())
    }

    func testInvalidLastName() throws {
        let userContent1 = UserContent(firstName: "")
        XCTAssertThrowsError(try userContent1.validate())
        let userContent2 = UserContent(firstName: "Popov92")
        XCTAssertThrowsError(try userContent2.validate())
        let userContent3 = UserContent(firstName: "Komarov*")
        XCTAssertThrowsError(try userContent3.validate())
    }

    func testInvalidUsername() throws {
        let userContent1 = UserContent(firstName: "")
        XCTAssertThrowsError(try userContent1.validate())
        let userContent2 = UserContent(firstName: "Sasako!")
        XCTAssertThrowsError(try userContent2.validate())
    }

    func testInvalidRegistrationDate() throws {
        let userContent = UserContent(registrationDate: Date().addingTimeInterval(500))
        XCTAssertThrowsError(try userContent.validate())
    }
}
