//
//  AuthToken.swift
//  App
//
//  Created by Vorona Vyacheslav on 1/2/20.
//

import Fluent
import FluentPostgreSQL
import Authentication
import DungeonChatCore

public final class AuthToken: PostgreSQLModel {
    public var id: Int?
    public private(set) var token: String
    public private(set) var userId: User.ID
    public private(set) var authDate: Date = Date()

    public var user: Parent<AuthToken, User> {
        parent(\.userId)
    }

    public init(token: String, userId: User.ID) {
        self.token = token
        self.userId = userId
    }
}

// MARK: - Vapor + Fluent

extension AuthToken: Migration {}
extension AuthToken: Content {}

// MARK: - Authentication

extension AuthToken: BearerAuthenticatable {

    public static var tokenKey: WritableKeyPath<AuthToken, String> {
        \.token
    }
}

extension AuthToken: Token {
    public typealias UserType = User
    public typealias UserIDType = User.ID

    public static var userIDKey: WritableKeyPath<AuthToken, User.ID> {
        \.userId
    }
}
