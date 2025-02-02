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
        let group = router.grouped(DungeonRoutes.Campaign.base.pathCompontent)
        group.get(Campaign.ID.parameter, use: getHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped(tokenAuthMiddleware)
        tokenAuthGroup.post(CampaignContent.self, use: createHandler)
        tokenAuthGroup.put(CampaignContent.self, at: Campaign.ID.parameter, use: updateHandler)
        tokenAuthGroup.delete(Campaign.ID.parameter, use: deleteHandler)
    }
}

// MARK: - Handlers

private extension CampaignController {

    func createHandler(_ request: Request, campaignContent: CampaignContent) throws -> Future<Campaign> {
        do {
            let user = try request.requireAuthenticated(User.self)
            guard let hostId = user.id else {
                throw Abort(.unauthorized, reason: "User id not found")
            }
            try campaignContent.validate()
            let newCampaign = try Campaign(campaignContent, hostId: hostId)
            return newCampaign.save(on: request)
        } catch DungeonError.missingContent(let message) {
            throw Abort(.badRequest, reason: message)
        }
    }
    
    func getHandler(_ request: Request) throws -> Future<Campaign> {
        let campaignId = try request.parameters.next(Campaign.ID.self)
        return Campaign.find(campaignId, on: request)
            .unwrap(or: Abort(.notFound, reason: "No Campaign with specified id"))
    }
    
    func updateHandler(_ request: Request, campaignContent: CampaignContent) throws -> Future<Campaign> {
        do {
            let user = try request.requireAuthenticated(User.self)
            guard let userId = user.id else {
                throw Abort(.unauthorized, reason: "User id not found")
            }
            guard campaignContent.containsUpdatable else {
                throw Abort(.badRequest, reason: "Request does not contain updatable data")
            }
            try campaignContent.validate()
            let campaignId = try request.parameters.next(Campaign.ID.self)
            return Campaign.find(campaignId, on: request)
                .unwrap(or: Abort(.notFound, reason: "No Campaign with specified id"))
                .flatMap { campaign -> Future<Campaign> in
                    guard campaign.hostId == userId else {
                        throw Abort(.forbidden, reason: "User is not able to modify specified Campaign")
                    }
                    return try campaign.update(from: campaignContent, on: request)
                }
                .flatMap { $0.update(on: request, originalID: campaignId)}
        } catch DungeonError.missingModel(let message) {
            throw Abort(.notFound, reason: message)
        }
    }
    
    func deleteHandler(_ request: Request) throws -> Future<HTTPResponseStatus> {
        let user = try request.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw Abort(.unauthorized, reason: "User id not found")
        }
        let campaignId = try request.parameters.next(Campaign.ID.self)
        return Campaign.find(campaignId, on: request)
            .unwrap(or: Abort(.notFound, reason: "No Campaign with specified id"))
            .flatMap { campaign in
                guard campaign.hostId == userId else {
                    throw Abort(.forbidden, reason: "User is not able to delete specified Campaign")
                }
                return campaign.delete(on: request).transform(to: .noContent)
            }
    }
}
