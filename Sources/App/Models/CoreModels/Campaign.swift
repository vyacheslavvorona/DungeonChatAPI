//
//  Campaign.swift
//  App
//
//  Created by vorona.vyacheslav on 2020/01/07.
//

import Vapor
import Fluent
import FluentPostgreSQL
import DungeonChatCore

final class Campaign: SharedCampaign {
    
    // Shared fields
    var id: Int?
    var name: String
    var hostId: User.ID
    var startDate: Date? = Date()
    var accessibilityInt: Int = 0
    
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
    
    convenience init(_ content: CampaignContent, hostId: User.ID) throws {
        guard let name = content.name else {
            throw DungeonError.missingContent(message: "Campaign name is missing")
        }
        self.init(name: name, hostId: hostId)
        
        if let accessibilityInt = content.accessibilityInt {
            self.accessibilityInt = accessibilityInt
        }
    }
    
    func update(from content: CampaignContent, on conn: DatabaseConnectable) throws -> Future<Campaign> {
        func updateWithPromise() -> Future<Campaign> {
            let promise: Promise<Campaign> = conn.eventLoop.newPromise()
            update(from: content)
            promise.succeed(result: self)
            return promise.futureResult
        }
        
        if let hostId = content.hostId {
            return User.find(hostId, on: conn).flatMap { user in
                guard user != nil else {
                    throw DungeonError.missingModel(message: "User to become Campaign Host not found")
                }
                return updateWithPromise()
            }
        }
        return updateWithPromise()
    }
}

// MARK: - Vapor + Fluent

extension Campaign: PostgreSQLModel {}
extension Campaign: Migration {}
extension Campaign: Content {}
extension Campaign: Parameter {}

// MARK: - Validatable

extension Campaign: Validatable {
    
    public static func validations() throws -> Validations<Campaign> {
        var validations = Validations(Campaign.self)
        try validations.add(\.id, .range(1...) || .nil)
        try validations.add(\.name, .characterSet(.alphanumerics + .whitespaces) && .contains(.letters))
        try validations.add(\.hostId, .range(1...))
        let accessTypesCount = CampaignAccessibilityType.allCases.count
        try validations.add(\.accessibilityInt, .range(0...accessTypesCount - 1))
        try validations.add(\.startDate, .past || .nil)
        return validations
    }
}

#if DEBUG
// MARK: - Unit test utilities
extension Campaign {

    func ut_setStartDate(_ date: Date) {
        startDate = date
    }
}
#endif
