//
//  UserController.swift
//  App
//
//  Created by Vorona Vyacheslav on 1/2/20.
//

import Authentication
import Crypto
import Random
import DungeonChatCore

class UserController: RouteCollection {

    func boot(router: Router) throws {
        let group = router.grouped(DungeonRoutes.User.base.pathCompontent)
        group.post(UserContent.self, at: DungeonRoutes.User.register.pathCompontent, use: registerHandler)
        group.post(UserContent.self, at: DungeonRoutes.User.login.pathCompontent, use: loginHandler)
        group.get(User.ID.parameter, use: getHandler)

        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped(tokenAuthMiddleware)
        tokenAuthGroup.put(UserContent.self, use: updateHandler)
    }
}

// MARK: - Handlers

private extension UserController {

    func registerHandler(_ request: Request, newUser: UserContent) throws -> Future<UserContent> {
        do {
            try newUser.validate()
            let user = try User(from: newUser)
            return User.query(on: request).filter(\.email == user.email).first()
                .flatMap { existingUser in
                    guard existingUser == nil else {
                        throw Abort(.badRequest, reason: "A User with this email already exists")
                    }
                    return user.save(on: request).map { $0.content }
                }
        } catch DungeonError.missingContent(let message) {
            throw Abort(.badRequest, reason: message)
        }
    }

    func loginHandler(_ request: Request, user: UserContent) throws -> Future<AuthToken> {
        guard let email = user.email else {
            throw Abort(.badRequest, reason: "Email is missing")
        }
        guard let password = user.password else {
            throw Abort(.badRequest, reason: "Password is missing")
        }
        return User.query(on: request).filter(\.email == email).first()
            .unwrap(or: Abort(.notFound, reason: "No User with specified email"))
            .flatMap { existingUser -> Future<AuthToken> in
                guard let userId = existingUser.id else {
                    throw Abort(.internalServerError, reason: "No User id")
                }
                let digest = try request.make(BCryptDigest.self)
                guard try digest.verify(password, created: existingUser.password) else {
                    throw Abort(.unauthorized, reason: "Wrong password")
                }

                return try existingUser.token.query(on: request).delete()
                    .flatMap { _ in
                        let tokenString = try URandom().generateData(count: 32).base64EncodedString()
                        let token = AuthToken(token: tokenString, userId: userId)
                        return token.save(on: request)
                    }
            }
    }

    func getHandler(_ request: Request) throws -> Future<UserContent> {
        let userId = try request.parameters.next(User.ID.self)
        return User.find(userId, on: request)
            .unwrap(or: Abort(.notFound, reason: "No User with specified id"))
            .map { $0.content }
    }

    func updateHandler(_ request: Request, userContent: UserContent) throws -> Future<UserContent> {
        let authenticated = try request.requireAuthenticated(User.self)
        guard let userId = authenticated.id else {
            throw Abort(.unauthorized, reason: "User id not found")
        }
        guard userContent.containsUpdatable else {
            throw Abort(.badRequest, reason: "Request does not contain updatable data")
        }
        try userContent.validate()
        return User.find(userId, on: request)
            .unwrap(or: Abort(.notFound, reason: "No User with specified id"))
            .flatMap { existingUser in
                existingUser.update(from: userContent)
                return existingUser.update(on: request, originalID: userId).map { $0.content }
            }
    }
}
