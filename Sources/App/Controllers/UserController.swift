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
        group.post(User.self, at: "register", use: registerUserHandler)
        group.post(User.self, at: "login", use: loginHandler)
    }
}

// MARK: - Handlers

private extension UserController {

    func registerUserHandler(_ request: Request, newUser: User) throws -> Future<User.Public> {
        guard newUser.email.stringIs(.email) else {
            throw Abort(.badRequest, reason: "Wrong email format")
        }

        return User.query(on: request).filter(\.email == newUser.email).first()
            .flatMap { existingUser in
                guard existingUser == nil else {
                    throw Abort(.badRequest, reason: "A user with this email already exists")
                }

                let digest = try request.make(BCryptDigest.self)
                let hashedPassword = try digest.hash(newUser.password)
                let user = User(email: newUser.email, password: hashedPassword)
                return user.save(on: request).map {
                    $0.publicUser
                }
            }
    }

    func loginHandler(_ request: Request, user: User) throws -> Future<AuthToken> {
        return User.query(on: request).filter(\.email == user.email).first()
            .flatMap { existingUser -> Future<AuthToken> in
                guard let existingUser = existingUser,
                    let userId = existingUser.id else {
                    throw Abort(.notFound, reason: "No user with this email")
                }
                let digest = try request.make(BCryptDigest.self)
                guard try digest.verify(user.password, created: existingUser.password) else {
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
}
