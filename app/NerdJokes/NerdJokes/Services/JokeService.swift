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
    
    func sync(completion: @escaping (Error?)->()) {
        serverSync { [weak self] error in
            guard error != nil else {
                completion(error)
                return
            }
            self?.localSync { localError in
                guard localError != nil else {
                    completion(localError)
                    return
                }
                completion(nil)
                
            }
        }
    }
    
    func serverSync(completion: @escaping (Error?)->()) {
        getChangesFromNetwork { [weak self] jokesToChange, error in
            guard error == nil else {
                completion(error)
                return
            }
            
            guard
                let this = self,
                jokesToChange.count > 0 else {
                    completion(nil)
                    return
            }
            for joke in jokesToChange {
                print(joke.setup)
                this.processChange(joke: joke)
            }
            do {
                try this.persistence.coreDataStack.save(childContext: this.persistence.coreDataStack.syncContext)
            } catch {
                completion(nil)
                return
            }
            completion(nil)
        }
    }
    
    func localSync(completion: @escaping (Error?)->()) {
        let jokes = persistence.getAll(context: persistence.coreDataStack.clientContext)
        let lastSyncedDate = Date(timeIntervalSince1970: LastSyncedSetting.value) as NSDate

        let createdTimePredicate = NSPredicate(format: "(createdTime > %@)", lastSyncedDate)
        let updatedTimePredicate = NSPredicate(format:  "(updatedTime > %@)", lastSyncedDate)
        let deletedTimePredicate = NSPredicate(format: "(deletedTime > %@)", lastSyncedDate)
     
        let newJokeChangesFilterResults = (jokes as NSArray).filtered(using: NSCompoundPredicate(type: .or, subpredicates: [createdTimePredicate, updatedTimePredicate, deletedTimePredicate]))
        
        for change in newJokeChangesFilterResults {
            guard let joke = change as? Joke else {
                return
            }
            
            processLocalChange(joke: joke) { error in
                guard error != nil else {
                    completion(error)
                    return
                }
            }
        }
        completion(nil)
    }
    
    
    
    func addJoke(joke: Joke) {
        persistence.coreDataStack.clientContext.insert(joke)
    }
    
    private func processLocalChange(joke: Joke, completion: @escaping ((Error?)->())) {
        guard let apiItem = Joke.apiItem(joke: joke) else {
            return
        }
        switch getMostRecentModificationType(joke: apiItem) {
        case .created:
            network.add(joke: apiItem, completion: { [weak self] serverID, error in
                guard
                    let this = self,
                    let serverID = serverID,
                    error != nil else {
                        print("can't parse server id")
                        completion(error)
                    return
                }
                joke.serverID = NSNumber(value: serverID.value)
               
                do {
                   try this.persistence.coreDataStack.save(childContext: this.persistence.coreDataStack.clientContext)
                } catch {}
                
            })
            break
        case .updated:
            network.update(joke: apiItem, completion: { success in
                print("updated = \(String(describing: success))")
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
            insertIntoSync(joke: joke)
            break
        case .updated:
            guard let clientID = joke.serverID else {
                return
            }
            guard let jokeToUpdate = persistence.get(id: clientID.value, context: persistence.coreDataStack.syncContext) else {
                return
            }
            updateIntoSync(jokeToUpdate: jokeToUpdate, setup: joke.setup, punchline: joke.punchline, votes: joke.votes)
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
        if isDeletedMostRecent(joke: joke) {
            return .deleted
        }
        
        guard let serverID = joke.serverID else {
            return .created
        }
        
        if persistence.get(id: serverID.value, context: persistence.coreDataStack.syncContext) != nil {
            return .updated
        }
        
        return .created
    }
    
    func isDeletedMostRecent(joke: JokeAPIItem) -> Bool {
        return joke.deletedTime ?? 0 > joke.createdTime && joke.deletedTime ?? 0 > joke.updatedTime ?? 0
    }
    
    private func getChangesFromNetwork(completion: @escaping ([JokeAPIItem], Error?)->()) {
        network.get { jokes, error in
            if let error = error {
                completion([], error)
            }
            
            let jokesToChange = jokes.filter({ joke in
                return self.isNewChange(joke: joke)
            })
            completion(jokesToChange, nil)
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
        joke.updatedTime = Date()
        joke.updatedUser = "phone"
        
        if let votes = votes {
            joke.votes = NSNumber(value: votes)
        }
        
        do {
            try persistence.coreDataStack.save(childContext: persistence.coreDataStack.clientContext)
        } catch {
            print("Cannot update joke")
        }
    }
    
    func updateIntoSync(jokeToUpdate joke: Joke, setup: String, punchline: String, votes: Int? = nil) {
        joke.setup = setup
        joke.punchline = punchline
        joke.updatedTime = Date()
        joke.updatedUser = "phone"
        
        if let votes = votes {
            joke.votes = NSNumber(value: votes)
        }
    }
    
    func insertIntoLocal(joke: JokeAPIItem) {
        Joke.from(jokeAPIItem: joke, context: persistence.coreDataStack.clientContext)
        do {
            try persistence.coreDataStack.save(childContext: persistence.coreDataStack.clientContext)
        } catch {}
        
    }
    
    func insertIntoLocal(setup: String, punchline: String, votes: Int? = nil) {
        Joke.insert(setup: setup, punchline: punchline, votes: 0, context: persistence.coreDataStack.clientContext)
        do {
            try persistence.coreDataStack.save(childContext: persistence.coreDataStack.clientContext)
        } catch {}
        
    }
    
    func insertIntoSync(joke: JokeAPIItem) {
        Joke.from(jokeAPIItem: joke, context: persistence.coreDataStack.syncContext)
    }
    
    func insertIntoSync(setup: String, punchline: String, votes: Int? = nil) {
        Joke.insert(setup: setup, punchline: punchline, votes: 0, context: persistence.coreDataStack.syncContext)
    }
    
    func deleteFromLocal(joke: Joke) {
        joke.deletedFlag = true
        joke.deletedTime = Date()
        do {
            try persistence.coreDataStack.save(childContext: persistence.coreDataStack.clientContext)
        } catch {}
    }
}

extension JokeService: JokePersistenceServiceDelegate {
    func clientContextDidMerge() {
        localSync(completion:{_ in})
    }
}
