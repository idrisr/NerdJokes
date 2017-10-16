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
        
        joke.createdTime = Date(timeIntervalSince1970: item.createdTime)
        joke.createdUser = item.createdUser ?? ""
        

        if let updatedTime = item.updatedTime {
            joke.updatedTime = Date(timeIntervalSince1970: updatedTime)
        }
        
        joke.updatedUser = item.updatedUser
        
        if let deletedSeconds = item.deletedTime {
            joke.deletedTime = Date(timeIntervalSince1970: deletedSeconds)
        }
        
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
        joke.createdTime = Date()
        joke.createdUser = "phone"
        joke.clientID = AppConstants.uuidString
        
        return joke
    }
    
    static func apiItem(joke: Joke) -> JokeAPIItem? {
        guard let clientID = joke.clientID else {
            print("Cannot convert Joke to api object.")
            return nil
        }
        return JokeAPIItem(clientID: ID(value: clientID),
                            setup: joke.setup,
                            punchline: joke.punchline,
                            votes: joke.votes.intValue,
                            createdTime: joke.createdTime.timeIntervalSince1970,
                            createdUser: joke.createdUser,
                            updatedTime: joke.updatedTime?.timeIntervalSince1970,
                            updatedUser: joke.updatedUser,
                            deletedTime: joke.deletedTime?.timeIntervalSince1970,
                            deletedUser: joke.deletedUser,
                            deletedFlag: joke.deletedFlag)
    }
}