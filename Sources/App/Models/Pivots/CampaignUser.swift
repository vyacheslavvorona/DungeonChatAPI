//
//  CampaignUser.swift
//  App
//
//  Created by Vorona Vyacheslav on 1/7/20.
//

import Fluent
import FluentPostgreSQL

struct CampaignUser: ModifiablePivot, PostgreSQLModel {
    typealias Left = Campaign
    typealias Right = User

    static var leftIDKey: LeftIDKey = \.campaignId
    static var rightIDKey: RightIDKey = \.userId

    var id: Int?
    var campaignId: Int
    var userId: Int

    init(_ campaign: Campaign, _ user: User) throws {
        campaignId = try campaign.requireID()
        userId = try user.requireID()
    }
}

extension CampaignUser: Migration {}
