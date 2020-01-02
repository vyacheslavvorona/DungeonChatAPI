//
//  User.swift
//  App
//
//  Created by Vorona Vyacheslav on 12/31/19.
//

import Vapor
import Fluent
import FluentSQLite
import DungeonChatCore
import Authentication

extension User: SQLiteUUIDModel {}
extension User: Migration {}
extension User: Content {}
extension User: Parameter {}

extension User {

    var auth: Children<User, UserAuth> {
        return children(\.userId)
    }

    var token: Children<User, AuthToken> {
        return children(\.userId)
    }
}

extension User: TokenAuthenticatable {
    public typealias TokenType = AuthToken
}
