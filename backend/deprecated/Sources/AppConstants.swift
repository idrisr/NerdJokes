//
//  AppConstants.swift
//  NerdJokesBackend
//
//  Created by Nicholas Lash on 10/4/17.
//
//

import Foundation

struct AppConstants {
    struct JokeKeys {
        static let kSetup = "setup"
        static let kPunchline = "punchline"
        static let kVotes = "votes"
        static let kID = "id"
    }
    
    struct ServerConfig {
        static let kPort: UInt16 = 8080
    }
    
    struct DatabaseConfig {
        static let kPath = "/app/nerdjokes/backend/nerdjokes.db"
    }
    
    struct DatabaseTables {
        static let kJoke = "joke"
    }
}