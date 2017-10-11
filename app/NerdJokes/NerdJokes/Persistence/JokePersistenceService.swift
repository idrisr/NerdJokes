//
//  JokePersistenceService.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/10/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation
import CoreData

class JokePersistenceService {
    var coreDataStack = CoreDataStack()
    var modificationState: ModificationState = .clean
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(localContextDidSave), name: Notification.Name.NSManagedObjectContextDidSave, object: coreDataStack.clientContext)
        NotificationCenter.default.addObserver(self, selector: #selector(syncContextDidSave), name: Notification.Name.NSManagedObjectContextDidSave, object: coreDataStack.syncContext)
    }
    
    func delete(joke: Joke, context: NSManagedObjectContext) {
        joke.deletedFlag = true
        joke.deletedTime = Date()
        do {
            try coreDataStack.save(childContext: context)
        } catch {
            print(error)
        }
    }
    
    func get(id: String, context: NSManagedObjectContext) -> Joke? {
        guard let jokes = context.registeredObjects as? Set<Joke> else {
            return nil
        }
        
        guard let joke = jokes.find(predicate: { joke in
            !joke.isFault && joke.remoteID == id
        }) else {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Joke")
            let predicate = NSPredicate(format: "remoteID = %@", id)
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.predicate = predicate
            do {
                guard let jokesFetchResult = try context.fetch(fetchRequest) as? [Joke],
                    let jokeMatch = jokesFetchResult.first else {
                    return nil
                }
                return jokeMatch
            } catch {
                print("\(error)")
            }
            return nil
        }
        
        return joke
    }
    
    func refreshClient() {
        do {
            try coreDataStack.clientContext.fetch(NSFetchRequest.init(entityName: "Joke"))
            modificationState = .clean
        } catch {
            print("\(error)")
        }
    }
    
    @objc func localContextDidSave(notification: Notification) {
        coreDataStack.syncContext.mergeChanges(fromContextDidSave: notification)
    }
    
    @objc func syncContextDidSave(notification: Notification) {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: AppConstants.Keys.kLastSyncSecondsSince1970)
    }
}
