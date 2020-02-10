//
//  User+Testable.swift
//  AppTests
//
//  Created by Vorona Vyacheslav on 1/13/20.
//

@ testable import App
import FluentPostgreSQL
import Authentication
import Random

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
        let user = User(email: email, password: hashedPassword)
        user.firstName = firstName
        user.lastName = lastName
        user.username = username
        return try user.save(on: conn).wait()
    }
    
    @discardableResult
    func authorize(on conn: PostgreSQLConnection) throws -> AuthToken {
        guard let id = id else { throw TestError(message: "No user id") }
        let tokenString = try URandom().generateData(count: 32).base64EncodedString()
        let token = AuthToken(token: tokenString, userId: id)
        return try token.save(on: conn).wait()
    }
    
    @discardableResult
    static func saveAndAuthorize(
        email: String,
        password: String,
        firstName: String? = nil,
        lastName: String? = nil,
        username: String? = nil,
        on conn: PostgreSQLConnection
    ) throws -> AuthToken {
        let savedUser = try save(email: email, password: password, firstName: firstName, lastName: lastName, username: username, on: conn)
        return try savedUser.authorize(on: conn)
    }
}
