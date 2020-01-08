//
//  CampaignController.swift
//  App
//
//  Created by Vorona Vyacheslav on 1/7/20.
//

import Authentication
import DungeonChatCore

class CampaignController: RouteCollection {

    func boot(router: Router) throws {
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = router.grouped(tokenAuthMiddleware)
        tokenAuthGroup.post(CampaignContent.self, at: "api", "campaigns", use: createCampaignHandler)
    }
}

// MARK: - Handlers

private extension CampaignController {

    func createCampaignHandler(_ request: Request, campaignContent: CampaignContent) throws -> Future<Campaign> {
        let user = try request.requireAuthenticated(User.self)
        guard let hostId = user.id else {
            throw Abort(.unauthorized, reason: "User id not found")
        }
        try campaignContent.validate()
        guard let newCampaign = Campaign(campaignContent, hostId: hostId) else {
            throw Abort(.internalServerError, reason: "Unable to create new Campaign")
        }
        return newCampaign.save(on: request)
    }
}
