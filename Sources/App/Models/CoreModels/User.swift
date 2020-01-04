//
//  User.swift
//  App
//
//  Created by Vorona Vyacheslav on 12/31/19.
//

import Vapor
import Fluent
import FluentSQLite
import Authentication
import DungeonChatCore

public final class User: SharedUser {

    // Shared fields
    public var id: Int?
    public private(set) var firstName: String?
    public private(set) var lastName: String?
    public private(set) var username: String?
    public private(set) var registrationDate: Date? = Date()

    public var structEmail: Email? {
        Email(email)
    }

    // Local fields
    private(set) var email: String
    private(set) var password: String

    init(email: Email, password: String) {
        self.email = email.stringValue
        self.password = password
    }
}

// MARK: - Public User

extension User {

    var publicUser: Public {
        Public(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            username: username,
            registrationDate: registrationDate
        )
    }

    struct Public: Content {
        var id: Int?
        var email: String?
        var firstName: String?
        var lastName: String?
        var username: String?
        var registrationDate: Date?
    }
}

// MARK: - Vapor + Fluent

extension User: SQLiteModel {}
extension User: Migration {}
extension User: Content {}
extension User: Parameter {}

// MARK: - TokenAuthenticatable

extension User: TokenAuthenticatable {
    public typealias TokenType = AuthToken

    var token: Children<User, AuthToken> {
        return children(\.userId)
    }
}
