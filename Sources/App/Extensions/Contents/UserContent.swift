//
//  UserContent.swift
//  App
//
//  Created by Vorona Vyacheslav on 1/6/20.
//

import Foundation
import DungeonChatCore
import Vapor

extension UserContent: Content {}
extension UserContent: Reflectable {}

extension UserContent: Validatable {
    
    public static func validations() throws -> Validations<UserContent> {
        var validations = Validations(UserContent.self)
        try validations.add(\.id, .range(1...) || .nil)
        try validations.add(\.email, .email || .nil)
        try validations.add(\.firstName, .letters && .count(2...) || .nil)
        try validations.add(\.lastName, .letters && .count(2...) || .nil)
        try validations.add(\.username, .alphanumeric && .count(2...) || .nil)
        return validations
    }
}
