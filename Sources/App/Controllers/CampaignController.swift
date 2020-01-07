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
        tokenAuthGroup.post(Campaign.self, at: "api", "campaigns", use: createCampaignHandler)
    }
}

// MARK: - Handlers

private extension CampaignController {

    func createCampaignHandler(_ request: Request, newCampaign: Campaign) throws -> Future<Campaign> {
        let user = try request.requireAuthenticated(User.self)
        try newCampaign.validate()
        newCampaign.
        // TODO: CampaignContent
        return User.query(on: request).filter(\.email == newUser.email).first()
            .flatMap { existingUser in
                guard existingUser == nil else {
                    throw Abort(.badRequest, reason: "A user with this email already exists")
                }

                let digest = try request.make(BCryptDigest.self)
                let hashedPassword = try digest.hash(newUser.password)
                let user = User(email: newUser.email, password: hashedPassword)
                return user.save(on: request).map { $0.content }
            }
    }
}
