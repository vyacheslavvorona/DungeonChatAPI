//
//  DungeonError.swift
//  App
//
//  Created by vorona.vyacheslav on 2020/02/21.
//

enum DungeonError: Error {
    case missingContent(message: String = "Unknown")
    case missingModel(message: String = "Unknown")
}
