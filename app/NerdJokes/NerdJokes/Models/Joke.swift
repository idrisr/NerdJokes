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
    @NSManaged var clientID: String?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Joke> {
        return NSFetchRequest<Joke>(entityName: "Joke");
    }
}

extension Joke {
    @discardableResult
    static func from(jokeAPIItem item: JokeAPIItem, context: NSManagedObjectContext) -> Joke {
        let entity = NSEntityDescription.entity(forEntityName: "Joke", in: context)!
        let joke = Joke(entity: entity, insertInto: context)
        
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
        joke.clientID = retrieveOrCreateClientID(jokeAPIItem: item)
       
        return joke
    }
    
    private static func retrieveOrCreateClientID(jokeAPIItem item: JokeAPIItem) -> String {
        guard let clientID = item.clientID else {
            return AppConstants.uuidString
        }
        return clientID.value
    }
    
    @discardableResult
    static func insert(setup: String, punchline: String, votes: Int, context: NSManagedObjectContext) -> Joke {
        let entity = NSEntityDescription.entity(forEntityName: "Joke", in: context)!
        let joke = Joke(entity: entity, insertInto: context)
        joke.setup = setup
        joke.punchline = punchline
        joke.votes = NSNumber(value: votes)
        joke.deletedFlag = false
        joke.createdTime = Date()
        joke.updatedTime = Date()
        joke.deletedTime = Date()
        joke.clientID = AppConstants.uuidString
        
        return joke
    }
}
