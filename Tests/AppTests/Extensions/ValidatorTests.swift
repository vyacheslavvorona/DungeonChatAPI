//
//  ValidatorTests.swift
//  AppTests
//
//  Created by Vorona Vyacheslav on 1/11/20.
//

import App
import XCTest
import Validation

final class ValidatorTests: XCTestCase {

    func testContains() throws {
        try Validator<String>.contains(.alphanumerics).validate("A#$%")
        try Validator<String>.contains(.alphanumerics).validate("1,-?")
        try Validator<String>.contains(.letters).validate("Z1))")
        try Validator<String>.contains(.uppercaseLetters).validate("1*bF")
        XCTAssertThrowsError(try Validator<String>.contains(.alphanumerics).validate("#$)*"))
        XCTAssertThrowsError(try Validator<String>.contains(.letters).validate("#$)*09"))
        XCTAssertThrowsError(try Validator<String>.contains(.uppercaseLetters).validate("yuo"))
    }

    func testPast() throws {
        try Validator<Date>.past.validate(Date().addingTimeInterval(-500))
        XCTAssertThrowsError(try Validator<Date>.past.validate(Date()))
        XCTAssertThrowsError(try Validator<Date>.past.validate(Date().addingTimeInterval(500)))
    }
}
