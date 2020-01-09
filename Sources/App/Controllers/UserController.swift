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
        let group = router.grouped("api", "users")
        group.post(User.self, at: "register", use: registerUserHandler)
        group.post(User.self, at: "login", use: loginHandler)
        group.get(Int.parameter, use: getHandler)

        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped(tokenAuthMiddleware)
        tokenAuthGroup.put(UserContent.self, use: updateHandler)
    }
}

// MARK: - Handlers

private extension UserController {

    func registerUserHandler(_ request: Request, newUser: User) throws -> Future<UserContent> {
        try newUser.validate()
        return User.query(on: request).filter(\.email == newUser.email).first()
            .flatMap { existingUser in
                guard existingUser == nil else {
                    throw Abort(.badRequest, reason: "A User with this email already exists")
                }

                let digest = try request.make(BCryptDigest.self)
                let hashedPassword = try digest.hash(newUser.password)
                let user = User(email: newUser.email, password: hashedPassword)
                return user.save(on: request).map { $0.content }
            }
    }

    func loginHandler(_ request: Request, user: User) throws -> Future<AuthToken> {
        guard user.email.stringIs(.email) else {
            throw Abort(.badRequest, reason: "Wrong email format")
        }

        return User.query(on: request).filter(\.email == user.email).first()
            .unwrap(or: Abort(.notFound, reason: "No User with specified email"))
            .flatMap { existingUser -> Future<AuthToken> in
                guard let userId = existingUser.id else {
                    throw Abort(.internalServerError, reason: "No User id")
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

    func getHandler(_ request: Request) throws -> Future<UserContent> {
        let userId = try request.parameters.next(Int.self)
        return User.find(userId, on: request)
            .unwrap(or: Abort(.notFound, reason: "No User with specified id"))
            .map { $0.content }
    }

    func updateHandler(_ request: Request, userContent: UserContent) throws -> Future<UserContent> {
        let authenticated = try request.requireAuthenticated(User.self)
        guard let userId = authenticated.id else {
            throw Abort(.unauthorized, reason: "User id not found")
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
