//
//  PersistenceService.swift
//  NerdNote
//
//  Created by Nicholas Lash on 10/4/17.
//
//

import Foundation
import StORM
import SQLiteStORM


class JokeAPI {
    private init() {}
    static let sharedInstance = JokeAPI()
    
    func setupDatabase() {
        SQLiteConnector.db = AppConstants.DatabaseConfig.kPath
        
        let setupObj = Joke()
        try? setupObj.setup()
    }
    
    func jokesToDictionary(jokes: [Joke]) -> [[String: Any]] {
        var json: [[String: Any]] = []
        for row in jokes {
            json.append(row.asDictionary())
        }
        return json
    }
    
    func allAsDictionary() throws -> [[String: Any]] {
        let jokes = try Joke.all()
        return jokesToDictionary(jokes: jokes)
    }
    
    func all() throws -> String {
        return try allAsDictionary().jsonEncodedString()
    }
    
    func delete(id: Int) throws -> String{
        let joke = try Joke.get(id: id)
        try joke.delete()
        return try all()
    }
    
    func test() throws -> String {
        let joke = Joke()
        joke.setup = "My Setup"
        joke.punchline = "My Punchline"
        joke.votes = 0
        
        try joke.save { id in
            joke.id = id as! Int
        }
        
        return try all()
    }
    
    func new(setup: String, punchline: String, votes: Int) throws -> [String: Any] {
        let joke = Joke()
        joke.setup = setup
        joke.punchline = punchline
        joke.votes = votes
        
        try joke.save { id in
            guard let id = id as? Int else {
                fatalError("Unexpected state. Server returned a bad ID.")
            }
            
            joke.id = id
        }
        
        return joke.asDictionary()
    }
    
    func new(json: String?) throws -> String {
        guard
            let json = json,
            let dictionary = try json.jsonDecode() as? [String: Any],
            let setup = dictionary[AppConstants.JokeKeys.kSetup] as? String,
            let punchline = dictionary[AppConstants.JokeKeys.kPunchline] as? String,
            let votes = dictionary[AppConstants.JokeKeys.kVotes] as? Int else {
                return "Invalid parameters"
        }
        
        return try new(setup: setup, punchline: punchline, votes: votes).jsonEncodedString()
    }
    
    func update(id: Int, json: String?) throws -> String {
        guard
            let json = json,
            let dictionary = try json.jsonDecode() as? [String: Any],
            let setup = dictionary[AppConstants.JokeKeys.kSetup] as? String,
            let punchline = dictionary[AppConstants.JokeKeys.kPunchline] as? String,
            let votes = dictionary[AppConstants.JokeKeys.kVotes] as? Int else {
                return "Invalid parameters"
        }
        
        let joke = try Joke.get(id: id)
        
        guard !joke.isEmpty else {
            return try new(setup: setup, punchline: punchline, votes: votes).jsonEncodedString()
        }
        
        joke.setup = setup
        joke.punchline = punchline
        joke.votes = votes
        try joke.save()
        
        return try joke.asDictionary().jsonEncodedString()
    }
}