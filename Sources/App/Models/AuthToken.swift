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
    var token: String
    var userAuthId: UserAuth.ID

    var userAuth: Parent<AuthToken, UserAuth> {
        return parent(\.userAuthId)
    }

    init(token: String, userAuthId: UserAuth.ID) {
        self.token = token
        self.userAuthId = userAuthId
    }
}

extension AuthToken: Migration {}
extension AuthToken: Content {}

extension AuthToken: BearerAuthenticatable {

    public static var tokenKey: WritableKeyPath<AuthToken, String> {
        \.token
    }
}

extension AuthToken: Token {
    public typealias UserType = UserAuth
    public typealias UserIDType = UserAuth.ID

    public static var userIDKey: WritableKeyPath<AuthToken, UserAuth.ID> {
        \.userAuthId
    }
}
