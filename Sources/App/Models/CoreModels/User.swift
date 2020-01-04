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

// MARK: - UserContent

extension UserContent: Content {}

extension User {
    
    var content: UserContent {
        UserContent(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            username: username,
            registrationDate: registrationDate
        )
    }

    func update(from content: UserContent) {
        if let contentEmail = content.email { email = contentEmail }
        if let contentFirstName = content.firstName { firstName = contentFirstName }
        if let contentLastName = content.lastName { lastName = contentLastName }
        if let contentUsername = content.username { username = contentUsername }
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
