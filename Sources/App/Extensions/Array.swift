//
//  Array.swift
//  App
//
//  Created by vorona.vyacheslav on 2020/01/20.
//

import Routing

public extension Array where Element == String {
    
    var pathCompontent: PathComponentsRepresentable {
        return self as [PathComponentsRepresentable]
    }
}
