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
    }
    
    func serverSync() {
        getChangesFromNetwork { [weak self] jokesToChange in
            guard
                let this = self,
                jokesToChange.count > 0 else {
                    return
            }
            for joke in jokesToChange {
                this.processChange(joke: joke)
            }
            
            this.persistence.modificationState = .dirty
            
            do {
                try this.persistence.coreDataStack.syncContext.save()
            } catch {
                print("\(error)")
            }
        }
    }
    
    func addJoke(joke: Joke) {
        persistence.coreDataStack.clientContext.insert(joke)
    }
    
    private func processChange(joke: JokeAPIItem) {
        switch getMostRecentModificationType(joke: joke) {
        case .created:
            Joke.from(jokeAPIItem: joke, context: persistence.coreDataStack.syncContext)
            break
        case .updated:
            guard let clientID = joke.clientID else {
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
            guard let clientID = joke.clientID else {
                return
            }
            guard let jokeToDelete = persistence.get(id: clientID.value, context: persistence.coreDataStack.syncContext) else {
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
