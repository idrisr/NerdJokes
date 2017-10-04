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
    
    struct DatabaseConfig {
        static let kHost = "localhost"
        static let kUsername = "perfect"
        static let kPassword = "password"
        static let kDatabase = "nerdjokes"
        static let kPort = 5432
    }
    
    struct DatabaseTables {
        static let kJoke = "joke"
    }
}
