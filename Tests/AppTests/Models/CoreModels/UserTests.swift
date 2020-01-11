//
//  User.swift
//  App
//
//  Created by Vorona Vyacheslav on 1/11/20.
//

import Foundation
import App
import XCTest
import DungeonChatCore

final class UserTests: XCTestCase {

    // MARK: - Validation

    func testCompleteModel() throws {
        let user = User.ut_init(email: "email@test.com", password: "lalo4ka$")
        user.id = 22
        user.firstName = "Andrey"
        user.lastName = "Govnenko"
        user.username = "Mamkoglad420"
        try user.validate()
    }

    func testMinimalModel() throws {
        try User.ut_init(email: "opop@test.com", password: "qwerty").validate()
    }

    func testInvalidId() throws {
        let user = User.ut_init(email: "email@test.com", password: "lalo4ka$")
        user.id = 0
        XCTAssertThrowsError(try user.validate())
        user.id = -123
        XCTAssertThrowsError(try user.validate())
    }

    func testInvalidEmail() throws {
        XCTAssertThrowsError(try User.ut_init(email: "some string", password: "lalo4ka$").validate())
        XCTAssertThrowsError(try User.ut_init(email: "email@test.comemail@test.com", password: "lalo4ka$").validate())
        XCTAssertThrowsError(try User.ut_init(email: "", password: "lalo4ka$").validate())
        XCTAssertThrowsError(try User.ut_init(email: " ", password: "lalo4ka$").validate())
        XCTAssertThrowsError(try User.ut_init(email: "asd@asd.45", password: "lalo4ka$").validate())
        XCTAssertThrowsError(try User.ut_init(email: "@asd.com", password: "lalo4ka$").validate())
        XCTAssertThrowsError(try User.ut_init(email: "asd@.com", password: "lalo4ka$").validate())
        XCTAssertThrowsError(try User.ut_init(email: "asd@asd.", password: "lalo4ka$").validate())
    }

    func testInvalidPassword() throws {
        XCTAssertThrowsError(try User.ut_init(email: "email@test.com", password: "a24!").validate())
        XCTAssertThrowsError(try User.ut_init(email: "email@test.com", password: "").validate())
        XCTAssertThrowsError(try User.ut_init(email: "email@test.com", password: "  ").validate())
    }

    func testInvalidFirstName() throws {
        let user = User.ut_init(email: "email@test.com", password: "lalo4ka$")
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
        let user = User.ut_init(email: "email@test.com", password: "lalo4ka$")
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
        let user = User.ut_init(email: "email@test.com", password: "lalo4ka$")
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
        let user = User.ut_init(email: "email@test.com", password: "lalo4ka$")
        user.ut_setRegistrationDate(Date().addingTimeInterval(500))
        XCTAssertThrowsError(try user.validate())
    }
}
