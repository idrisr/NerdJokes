//
//  Joke.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/10/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation
import CoreData

class Joke: Trackable {
    @NSManaged var setup: String
    @NSManaged var punchline: String
    @NSManaged var votes: NSNumber
    @NSManaged var remoteID: String
}

extension Joke {
    @discardableResult
    static func from(jokeAPIItem item: JokeAPIItem, context: NSManagedObjectContext) -> Joke {
        let joke = Joke(entity: Joke.entity(), insertInto: context)
        
        joke.setup = item.setup
        joke.punchline = item.punchline
        joke.votes = NSNumber(value: item.votes)
        
        joke.createdTime = Date(timeIntervalSince1970: Double(item.createdTime))
        joke.createdUser = item.createdUser
        joke.updatedTime = Date(timeIntervalSince1970: Double(item.updatedTime))
        joke.updatedUser = item.updatedUser
        joke.deletedTime = Date(timeIntervalSince1970: Double(item.deletedTime))
        joke.deletedUser = item.deletedUser
        joke.deletedFlag = item.deletedFlag
        joke.remoteID = item.id.value

        return joke
    }
    
    @discardableResult
    static func insert(setup: String, punchline: String, votes: Int, context: NSManagedObjectContext) -> Joke {
        let joke = Joke(entity: Joke.entity(), insertInto: context)
        joke.setup = setup
        joke.punchline = punchline
        joke.votes = NSNumber(value: votes)
        joke.deletedFlag = false
        joke.createdTime = Date()
        joke.updatedTime = Date()
        joke.deletedTime = Date()
        
        return joke
    }
}
