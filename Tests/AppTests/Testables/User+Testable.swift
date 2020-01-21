//
//  User+Testable.swift
//  AppTests
//
//  Created by Vorona Vyacheslav on 1/13/20.
//

import App
import FluentPostgreSQL
import Authentication

extension User {

    @discardableResult
    static func save(
        email: String,
        password: String,
        firstName: String? = nil,
        lastName: String? = nil,
        username: String? = nil,
        on conn: PostgreSQLConnection
    ) throws -> User {
        let hashedPassword = try BCrypt.hash(password)
        let user = User.ut_init(email: email, password: hashedPassword)
        user.firstName = firstName
        user.lastName = lastName
        user.username = username
        return try user.save(on: conn).wait()
    }
}
