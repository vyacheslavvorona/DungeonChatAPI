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
        tokenAuthGroup.put(CampaignContent.self, at: "api", "campaigns", Int.parameter, use: updateCampaignHandler)
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
    
    func updateCampaignHandler(_ request: Request, campaignContent: CampaignContent) throws -> Future<Campaign> {
        let user = try request.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw Abort(.unauthorized, reason: "User id not found")
        }
        let campaignId = try request.parameters.next(Int.self)
        return Campaign.find(campaignId, on: request)
            .flatMap { campaign -> Future<Campaign> in
                guard let campaign = campaign, campaign.hostId == userId else {
                    throw Abort(.forbidden, reason: "User is not able to modify specified Campaign")
                }
                return try campaign.update(from: campaignContent, on: request)
            }
            .flatMap { $0.update(on: request, originalID: campaignId)}
    }
}
