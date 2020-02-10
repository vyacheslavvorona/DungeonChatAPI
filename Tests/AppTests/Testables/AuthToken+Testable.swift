//
//  AuthToken+Testable.swift
//  AppTests
//
//  Created by vorona.vyacheslav on 2020/01/23.
//

@ testable import App

extension AuthToken {
    
    var headerValue: String {
        "Bearer \(token)"
    }
}
