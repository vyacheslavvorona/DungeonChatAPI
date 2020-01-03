//
//  UserController.swift
//  App
//
//  Created by Vorona Vyacheslav on 1/2/20.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite
import Crypto
import Random
import DungeonChatCore

class UserController: RouteCollection {

    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        group.post(UserAuth.self, at: "register", use: registerUserHandler)
        group.post(UserAuth.self, at: "login", use: loginHandler)
    }
}

// MARK: - Handlers

private extension UserController {

    func registerUserHandler(_ request: Request, newUserAuth: UserAuth) throws -> Future<HTTPResponseStatus> {
        return UserAuth.query(on: request).filter(\.email == newUserAuth.email).first()
            .map {
                if $0 != nil {
                    throw Abort(.badRequest, reason: "A user with this email already exists")
                }
            }
            .flatMap { User().save(on: request) }
            .flatMap { user in
                guard let userId = user.id else {
                    throw Abort(.internalServerError, reason: "Could not create a new user")
                }
                let digest = try request.make(BCryptDigest.self)
                let hashedPassword = try digest.hash(newUserAuth.password)
                let userAuth = UserAuth(userId: userId, email: newUserAuth.email, password: hashedPassword)
                return userAuth.save(on: request).transform(to: .created)
            }
    }

    func loginHandler(_ request: Request, userAuth: UserAuth) throws -> Future<AuthToken> {
        return UserAuth.query(on: request).filter(\.email == userAuth.email).first()
            .flatMap { existingAuth -> Future<AuthToken> in
                guard let existingAuth = existingAuth else {
                    throw Abort(.notFound, reason: "No user with this email")
                }
                guard let authId = existingAuth.id else {
                    throw Abort(.internalServerError, reason: "UserAuth.id is missing")
                }
                let digest = try request.make(BCryptDigest.self)
                guard try digest.verify(userAuth.password, created: existingAuth.password) else {
                    throw Abort(.unauthorized, reason: "Wrong password")
                }

                return try existingAuth.token.query(on: request).delete()
                    .flatMap { _ in
                        let tokenString = try URandom().generateData(count: 32).base64EncodedString()
                        let token = AuthToken(token: tokenString, userAuthId: authId)
                        return token.save(on: request)
                    }
            }
    }
}
