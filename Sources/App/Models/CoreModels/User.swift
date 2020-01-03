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

extension User: SQLiteModel {}
extension User: Migration {}
extension User: Content {}
extension User: Parameter {}

extension User {

    var auth: Children<User, UserAuth>? {
        return children(\.userId)
    }
}
