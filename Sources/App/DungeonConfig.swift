//
//  Config.swift
//  App
//
//  Created by vorona.vyacheslav on 2020/01/10.
//

import FluentPostgreSQL

public enum DungeonConfig {
    case local
    
    static var current: DungeonConfig {
        return .local
    }
}

public enum CurrentPostgreSQLConfig {
    
    static var hostname: String {
        switch DungeonConfig.current {
        case .local: return "localhost"
        }
    }
    
    static var port: Int {
        return 5432
    }
    
    static var username: String {
        switch DungeonConfig.current {
        case .local: return "skolvan"
        }
    }
    
    static var database: String {
        switch DungeonConfig.current {
        case .local: return "mydungeon"
        }
    }
    
    static var password: String {
        switch DungeonConfig.current {
        case .local: return "skolvanpass42"
        }
    }
    
    static var transport: PostgreSQLConnection.TransportConfig {
        switch DungeonConfig.current {
        case .local: return .cleartext
        }
    }
}


