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

final class UserAuth: Content, SQLiteUUIDModel, Migration {
    var id: UUID?
    var userId: User.ID?
    private(set) var email: String
    private(set) var password: String

    var user: Parent<UserAuth, User>? {
        return parent(\.userId)
    }

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
