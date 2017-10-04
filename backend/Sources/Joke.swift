//
//  Note.swift
//  NerdNote
//
//  Created by Nicholas Lash on 10/4/17.
//
//

import Foundation
import StORM
import SQLiteStORM

class Joke: SQLiteStORM {
    var id: Int = 0
    var setup: String = ""
    var punchline: String = ""
    var votes: Int = 0
    
    override func table() -> String {
        return AppConstants.DatabaseTables.kJoke
    }
    
    override func to(_ this: StORMRow) {
        id = this.data[AppConstants.JokeKeys.kID] as? Int ?? 0
        setup = this.data[AppConstants.JokeKeys.kSetup] as? String ?? ""
        punchline = this.data[AppConstants.JokeKeys.kPunchline] as? String ?? ""
        votes = this.data[AppConstants.JokeKeys.kVotes] as? Int ?? 0
    }
    
    var isEmpty: Bool {
        return id == 0 && setup == "" && punchline == ""
    }
}

// MARK: - Helper methods
extension Joke {
    func asDictionary()  -> [String: Any] {
        return [
            AppConstants.JokeKeys.kID: id,
            AppConstants.JokeKeys.kSetup: setup,
            AppConstants.JokeKeys.kPunchline: punchline,
            AppConstants.JokeKeys.kVotes: votes
        ]
    }
    
    func rows() -> [Joke] {
        var rows = [Joke]()
        for i in 0..<results.rows.count {
            let row = Joke()
            row.to(results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    static func all() throws -> [Joke] {
        let getObj = Joke()
        try getObj.findAll()
        return getObj.rows()
    }
    
    static func get(id: Int) throws -> Joke {
        let getObj = Joke()
        var findObj = [String: Any]()
        findObj[AppConstants.JokeKeys.kID] = "\(id)"
        try getObj.find(findObj)
        return getObj
    }
}
