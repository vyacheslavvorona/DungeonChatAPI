//
//  AuthToken.swift
//  App
//
//  Created by Vorona Vyacheslav on 1/2/20.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite
import Authentication
import DungeonChatCore

public final class AuthToken: SQLiteUUIDModel {
    public var id: UUID?
    public var token: String
    public var userId: User.ID

    var user: Parent<AuthToken, User> {
        return parent(\.userId)
    }

    init(token: String, userId: User.ID) {
        self.token = token
        self.userId = userId
    }
}

extension AuthToken: Migration {}

extension AuthToken: BearerAuthenticatable {

    public static var tokenKey: WritableKeyPath<AuthToken, String> {
        \.token
    }
}

extension AuthToken: Token {
    public typealias UserType = User
    public typealias UserIDType = UUID

    public static var userIDKey: WritableKeyPath<AuthToken, User.ID> {
        \.userId
    }
}
