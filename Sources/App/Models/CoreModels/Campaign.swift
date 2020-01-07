//
//  Campaign.swift
//  App
//
//  Created by vorona.vyacheslav on 2020/01/07.
//

import Vapor
import Fluent
import FluentSQLite
import DungeonChatCore

public final class Campaign: SharedCampaign {
    
    // Shared fields
    public var id: Int?
    public private(set) var name: String
    public private(set) var hostId: User.ID
    public private(set) var startDate: Date? = Date()
    public private(set) var accessibilityInt: Int = 0
    
    var host: Parent<Campaign, User> {
        parent(\.hostId)
    }

    var participants: Siblings<Campaign, User, CampaignUser> {
        siblings()
    }
    
    init(name: String, hostId: User.ID) {
        self.name = name
        self.hostId = hostId
    }
}

// MARK: - Vapor + Fluent

extension Campaign: SQLiteModel {}
extension Campaign: Migration {}
extension Campaign: Content {}
extension Campaign: Parameter {}

// MARK: - Validatable

extension Campaign: Validatable {
    
    public static func validations() throws -> Validations<Campaign> {
        var validations = Validations(Campaign.self)
        try validations.add(\.name, .alphanumeric)
        try validations.add(\.hostId, .range(1...))
        let accessTypesCount = CampaignAccessibilityType.allCases.count
        try validations.add(\.hostId, .range(0...accessTypesCount - 1))
        return validations
    }
}
