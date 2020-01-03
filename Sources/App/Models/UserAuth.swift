//
//  UserAuth.swift
//  App
//
//  Created by Vorona Vyacheslav on 1/2/20.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite
import DungeonChatCore
import Authentication

public final class UserAuth: Content, SQLiteUUIDModel, Migration {
    public var id: UUID?
    var userId: User.ID?
    private(set) var email: String
    private(set) var password: String

    var user: Parent<UserAuth, User>? {
        return parent(\.userId)
    }

    var token: Children<UserAuth, AuthToken> {
        return children(\.userAuthId)
    }

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

extension UserAuth: TokenAuthenticatable {
    public typealias TokenType = AuthToken
}
