//
//  JokeService.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/11/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation

class JokeService {
    var persistence: JokePersistenceService!
    var network: JokeNetworkService!
    
    required init(persistence: JokePersistenceService, network: JokeNetworkService) {
        self.persistence = persistence
        self.network = network
        self.persistence.delegate = self
    }
    
    func sync(completion: @escaping ()->()) {
        serverSync { [weak self] in
            self?.localSync {
                completion()
            }
        }
    }
    
    func serverSync(completion: @escaping ()->()) {
        getChangesFromNetwork { [weak self] jokesToChange in
            guard
                let this = self,
                jokesToChange.count > 0 else {
                    completion()
                    return
            }
            for joke in jokesToChange {
                this.processChange(joke: joke)
            }
            
            this.persistence.modificationState = .dirty
            
            do {
                try this.persistence.coreDataStack.syncContext.save()
                completion()
            } catch {
                print("\(error)")
                completion()
            }
        }
    }
    
    func localSync(completion: ()->()) {
        guard let items = persistence.coreDataStack.clientContext.registeredObjects as? Set<Joke> else {
            return
        }
        let jokes: [Joke] = Array(items)
        
        let lastSyncedDate = Date(timeIntervalSince1970: LastSyncedSetting.value) as NSDate
        let createdPredicate = NSPredicate(format: "createdTime > %@", lastSyncedDate)
        let updatedPredicate = NSPredicate(format: "updatedTime > %@", lastSyncedDate)
        let deletedPredicate = NSPredicate(format: "deletedTime > %@", lastSyncedDate)
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [createdPredicate, updatedPredicate, deletedPredicate])
     
        let newJokeChangesFilterResults = (jokes as NSArray).filtered(using: compoundPredicate)
        for change in newJokeChangesFilterResults {
            guard let joke = change as? Joke else {
                return
            }
            processLocalChange(joke: joke)
        }
        completion()
    }
    
    
    
    func addJoke(joke: Joke) {
        persistence.coreDataStack.clientContext.insert(joke)
    }
    
    private func processLocalChange(joke: Joke) {
        guard let apiItem = Joke.apiItem(joke: joke) else {
            return
        }
        switch getMostRecentModificationType(joke: apiItem) {
        case .created:
            network.add(joke: apiItem, completion: { [weak self] serverID in
                guard
                    let this = self,
                    let serverID = serverID else {
                    print("can't parse server id")
                    return
                }
                joke.serverID = NSNumber(value: serverID.value)
                do {
                    try this.persistence.coreDataStack.save(childContext: this.persistence.coreDataStack.clientContext)
                } catch {
                    print("Cannot set new id \(error)")
                }
            })
            break
        case .updated:
            network.update(joke: apiItem, completion: { success in
                print("updated = \(success)")
            })
            break
        case .deleted:
            guard let id = apiItem.serverID else {
                return
            }
            network.delete(id: id, completion: { success in
                print("deleted = \(success)")
            })
            break
        }
    }
    
    private func processChange(joke: JokeAPIItem) {
        switch getMostRecentModificationType(joke: joke) {
        case .created:
            Joke.from(jokeAPIItem: joke, context: persistence.coreDataStack.syncContext)
            break
        case .updated:
            guard let clientID = joke.serverID else {
                return
            }
            guard let jokeToUpdate = persistence.get(id: clientID.value, context: persistence.coreDataStack.syncContext) else {
                return
            }
            jokeToUpdate.setup = joke.setup
            jokeToUpdate.punchline = joke.punchline
            jokeToUpdate.votes = NSNumber(value: joke.votes)
            jokeToUpdate.updatedTime = Date()
            break
        case .deleted:
            guard let serverID = joke.serverID else {
                return
            }
            guard let jokeToDelete = persistence.get(id: serverID.value, context: persistence.coreDataStack.syncContext) else {
                return
            }
            persistence.delete(joke: jokeToDelete, context: persistence.coreDataStack.syncContext)
            break
        }
    }
    
    private func getMostRecentModificationType(joke: JokeAPIItem) -> ModificationType {
        if isUpdatedMostRecent(joke: joke) {
            return .updated
        }
        
        if isCreatedMostRecent(joke: joke) {
            return .created
        }
        
        return .deleted
    }
    
    func isUpdatedMostRecent(joke: JokeAPIItem) -> Bool {
        guard let updatedTime = joke.updatedTime else {
            return false
        }
        
        if joke.createdTime > updatedTime {
            return false
        }
        
        if let deletedTime = joke.deletedTime, deletedTime > updatedTime {
            return false
        }
        
        return true
    }
    
    func isCreatedMostRecent(joke: JokeAPIItem) -> Bool {
        if let updatedTime = joke.updatedTime, updatedTime > joke.createdTime {
            return false
        }
        
        if let deletedTime = joke.deletedTime, deletedTime > joke.createdTime {
            return false
        }
        
        return true
    }
    
    private func getChangesFromNetwork(completion: @escaping ([JokeAPIItem])->()) {
        network.get { jokes in
            let jokesToChange = jokes.filter({ joke in
                return self.isNewChange(joke: joke)
            })
            completion(jokesToChange)
        }
    }
    
    private func isNewChange(joke: JokeAPIItem) -> Bool {
        let lastSyncDate = LastSyncedSetting.value
        return joke.createdTime > lastSyncDate ||
                joke.deletedTime ?? joke.createdTime > lastSyncDate ||
                joke.updatedTime ?? joke.createdTime > lastSyncDate
    }
    
    func updateIntoLocal(jokeToUpdate joke: Joke, setup: String, punchline: String, votes: Int? = nil) {
        joke.setup = setup
        joke.punchline = punchline
        
        if let votes = votes {
            joke.votes = NSNumber(value: votes)
        }
        
        do {
            try persistence.coreDataStack.save(childContext: persistence.coreDataStack.clientContext)
        } catch {
            print("Cannot update joke")
        }
    }
    
    func insertIntoLocal(joke: JokeAPIItem) {
        Joke.from(jokeAPIItem: joke, context: persistence.coreDataStack.clientContext)
        
        do {
            try persistence.coreDataStack.save(childContext: persistence.coreDataStack.clientContext)
        } catch {
            print("Cannot add joke")
        }
    }
    
    func insertIntoLocal(setup: String, punchline: String, votes: Int? = nil) {
        Joke.insert(setup: setup, punchline: punchline, votes: 0, context: persistence.coreDataStack.clientContext)
        do {
            try persistence.coreDataStack.save(childContext: persistence.coreDataStack.clientContext)
        } catch {
            print("Cannot delete joke")
        }
    }
    
    func deleteFromLocal(joke: Joke) {
        joke.deletedFlag = true
        do {
            try persistence.coreDataStack.save(childContext: persistence.coreDataStack.clientContext)
        } catch {
            print("Cannot delete joke")
        }
    }
}

extension JokeService: JokePersistenceServiceDelegate {
    func clientContextDidMerge() {
        localSync(completion:{})
    }
}
