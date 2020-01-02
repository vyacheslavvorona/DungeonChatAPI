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
import DungeonChatCore

class UserController: RouteCollection {

    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        group.post(UserAuth.self, at: "register", use: registerUserHandler)
    }
}

//MARK: Helper
private extension UserController {

    func registerUserHandler(_ request: Request, newUserAuth: UserAuth) throws -> Future<HTTPResponseStatus> {
        return UserAuth.query(on: request).filter(\.email == newUserAuth.email).first()
            .map {
                if $0 != nil {
                    throw Abort(.badRequest, reason: "A user with this email already exists" , identifier: nil)
                }
            }
            .flatMap { User().save(on: request) }
            .flatMap { user in
                guard let userId = user.id else {
                    throw Abort(.internalServerError, reason: "Could not create a new user" , identifier: nil)
                }
                let digest = try request.make(BCryptDigest.self)
                let hashedPassword = try digest.hash(newUserAuth.password)
                let userAuth = UserAuth(userId: userId, email: newUserAuth.email, password: hashedPassword)
                return userAuth.save(on: request).transform(to: .created)
            }
    }
}
