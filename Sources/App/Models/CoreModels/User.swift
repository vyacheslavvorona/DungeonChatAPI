//
//  User.swift
//  App
//
//  Created by Vorona Vyacheslav on 12/31/19.
//

import Vapor
import Fluent
import FluentPostgreSQL
import Authentication
import DungeonChatCore

public final class User: SharedUser {

    // Shared fields
    public var id: Int?
    public var email: String
    public var firstName: String?
    public var lastName: String?
    public var username: String?
    public private(set) var registrationDate: Date? = Date()

    // Local fields
    private(set) var password: String

    var hostedCampaigns: Children<User, Campaign> {
        children(\.hostId)
    }

    var participatedCampaigns: Siblings<User, Campaign, CampaignUser> {
        siblings()
    }
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }

    init(email: Email, password: String) {
        self.email = email.stringValue
        self.password = password
    }
}

// MARK: - Vapor + Fluent

extension User: PostgreSQLModel {}
extension User: Migration {}
extension User: Content {}
extension User: Parameter {}

// MARK: - TokenAuthenticatable

extension User: TokenAuthenticatable {
    public typealias TokenType = AuthToken

    var token: Children<User, AuthToken> {
        children(\.userId)
    }
}

// MARK: - Validatable

extension User: Validatable {
    
    public static func validations() throws -> Validations<User> {
        var validations = Validations(User.self)
        try validations.add(\.email, .email)
        try validations.add(\.password, .ascii && .count(5...))
        try validations.add(\.firstName, .letters && .count(2...) || .nil)
        try validations.add(\.lastName, .letters && .count(2...) || .nil)
        try validations.add(\.username, .alphanumeric && .contains(.letters) && .count(2...) || .nil)
        return validations
    }
}
