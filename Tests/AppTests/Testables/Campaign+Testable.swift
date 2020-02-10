//
//  Campaign+Testable.swift
//  AppTests
//
//  Created by vorona.vyacheslav on 2020/02/10.
//

@testable import App
import FluentPostgreSQL

extension Campaign {
    
    @discardableResult
    static func save(
        name: String,
        hostId: User.ID,
        accessibilityInt: Int,
        conn: PostgreSQLConnection
    ) throws -> Campaign {
        let campaign = Campaign(name: name, hostId: hostId)
        campaign.accessibilityInt = accessibilityInt
        return try campaign.save(on: conn).wait()
    }
}
