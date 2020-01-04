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
    private var _registrationDate: String? = Date().iso8601

    public var registrationDate: Date? {
        guard let string = _registrationDate else { return nil }
        return string.iso8601
    }

    // Local fields
    private(set) var email: String
    private(set) var password: String

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

extension User: SQLiteModel {}
extension User: Migration {}
extension User: Content {}
extension User: Parameter {}

extension User: TokenAuthenticatable {
    public typealias TokenType = AuthToken

    var token: Children<User, AuthToken> {
        return children(\.userId)
    }
}
