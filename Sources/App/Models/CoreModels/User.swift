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

extension User: SQLiteUUIDModel {}
extension User: Migration {}
extension User: Content {}
extension User: Parameter {}
