//
//  CampaignContent.swift
//  App
//
//  Created by vorona.vyacheslav on 2020/01/08.
//

import DungeonChatCore
import Vapor

extension CampaignContent: Content {}
extension CampaignContent: Reflectable {}

extension CampaignContent: Validatable {
    
    public static func validations() throws -> Validations<CampaignContent> {
        var validations = Validations(CampaignContent.self)
        try validations.add(\.id, .range(1...) || .nil)
        try validations.add(\.name, .characterSet(.alphanumerics + .whitespaces) && .contains(.letters) || .nil)
        try validations.add(\.hostId, .range(1...) || .nil)
        let accessTypesCount = CampaignAccessibilityType.allCases.count
        try validations.add(\.accessibilityInt, .range(0...accessTypesCount - 1) || .nil)
        try validations.add(\.startDate, .past || .nil)
        return validations
    }
}
