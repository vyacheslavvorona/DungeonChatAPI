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
import Authentication

struct UserAuth: Content, SQLiteUUIDModel, Migration {
    var id: UUID?
    var userId: UUID?
    private(set) var email: String
    private(set) var password: String

    init(userId: UUID, email: String, password: String) {
        self.userId = userId
        self.email = email
        self.password = password
    }
}

extension UserAuth: BasicAuthenticatable {
   static let usernameKey: WritableKeyPath<UserAuth, String> = \.email
   static let passwordKey: WritableKeyPath<UserAuth, String> = \.password
}
