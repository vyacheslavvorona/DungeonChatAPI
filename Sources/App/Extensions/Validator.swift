//
//  Validator.swift
//  App
//
//  Created by vorona.vyacheslav on 2020/01/06.
//

import Foundation
import Validation

extension Validator {
    
    static var letters: Validator<String> {
        return .characterSet(.letters)
    }
}
