//
//  UserContentTests.swift
//  AppTests
//
//  Created by Vorona Vyacheslav on 1/11/20.
//

import Foundation
@ testable import App
import XCTest
import DungeonChatCore

final class UserContentTests: XCTestCase {

    func testCompleteContent() throws {
        try UserContent(
            id: 42,
            email: "email@test.com",
            firstName: "Ivan",
            lastName: "Petrov",
            username: "Nagibator69",
            registrationDate: Date()
        ).validate()
    }

    func testNilContent() throws {
        try UserContent().validate()
    }

    func testInvalidId() throws {
        XCTAssertThrowsError(try UserContent(id: 0).validate())
        XCTAssertThrowsError(try UserContent(id: -3).validate())
    }

    func testInvalidEmail() throws {
        XCTAssertThrowsError(try UserContent(email: "email@test.comemail@test.com").validate())
        XCTAssertThrowsError(try UserContent(email: "").validate())
        XCTAssertThrowsError(try UserContent(email: " ").validate())
        XCTAssertThrowsError(try UserContent(email: "asd@asd.45").validate())
        XCTAssertThrowsError(try UserContent(email: "@asd.com").validate())
        XCTAssertThrowsError(try UserContent(email: "asd@.com").validate())
        XCTAssertThrowsError(try UserContent(email: "asd@asd.").validate())
    }

    func testInvalidFirstName() throws {
        XCTAssertThrowsError(try UserContent(firstName: "").validate())
        XCTAssertThrowsError(try UserContent(firstName: " ").validate())
        XCTAssertThrowsError(try UserContent(firstName: "Y").validate())
        XCTAssertThrowsError(try UserContent(firstName: "Petr4").validate())
        XCTAssertThrowsError(try UserContent(firstName: "Oleg&").validate())
    }

    func testInvalidLastName() throws {
        XCTAssertThrowsError(try UserContent(lastName: "").validate())
        XCTAssertThrowsError(try UserContent(lastName: " ").validate())
        XCTAssertThrowsError(try UserContent(lastName: "M").validate())
        XCTAssertThrowsError(try UserContent(lastName: "Popov92").validate())
        XCTAssertThrowsError(try UserContent(lastName: "Komarov*").validate())
    }

    func testInvalidUsername() throws {
        XCTAssertThrowsError(try UserContent(username: "").validate())
        XCTAssertThrowsError(try UserContent(username: " ").validate())
        XCTAssertThrowsError(try UserContent(username: "Sasako!").validate())
    }

    func testInvalidRegistrationDate() throws {
        XCTAssertThrowsError(try UserContent(registrationDate: Date().addingTimeInterval(500)).validate())
    }
}
