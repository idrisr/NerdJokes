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
            if let error = error {
                completion(error)
            }
            
            guard
                let this = self,
                jokesToChange.count > 0 else {
                    completion(nil)
                    return
            }
            for joke in jokesToChange {
                this.processChange(joke: joke)
            }
            
            this.persistence.modificationState = .dirty
            
            do {
                try this.persistence.coreDataStack.syncContext.save()
                completion(nil)
            } catch {
                print("\(error)")
                completion(nil)
            }
        }
    }
    
    func localSync(completion: @escaping (Error?)->()) {
        let jokes = persistence.getAll(context: persistence.coreDataStack.clientContext)
        
        let lastSyncedDate = Date(timeIntervalSince1970: LastSyncedSetting.value) as NSDate

        let createdTimePredicate = NSPredicate(format: "(createdTime > %@)", lastSyncedDate)
        let updatedTimePredicate = NSPredicate(format:  "(updatedTime > %@)", lastSyncedDate)
        let deletedTimePredicate = NSPredicate(format: "(deletedTime > %@)", lastSyncedDate)
     
        let newJokeChangesFilterResults = (jokes as NSArray).filtered(using: NSCompoundPredicate(type: .or, subpredicates: [createdTimePredicate, updatedTimePredicate, deletedTimePredicate]))
        
        
        let dispatchGroup = DispatchGroup()
        var hasError = false

        for change in newJokeChangesFilterResults {
            dispatchGroup.enter()
            guard let joke = change as? Joke else {
                return
            }
            
            
            processLocalChange(joke: joke) { error in
                guard error != nil else {
                    completion(error)
                    hasError = true
                    dispatchGroup.leave()
                    return
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.wait()
        if !hasError {
            LastSyncedSetting.value = Date().timeIntervalSince1970
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
        if isDeletedMostRecent(joke: joke) {
            return .deleted
        }
        
        if persistence.jokeExistsInContext(id: joke.serverID!.value, context: persistence.coreDataStack.clientContext) != nil {
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
        joke.deletedTime = Date()
        do {
            try persistence.coreDataStack.save(childContext: persistence.coreDataStack.clientContext)
        } catch {
            print("Cannot delete joke")
        }
    }
}

extension JokeService: JokePersistenceServiceDelegate {
    func clientContextDidMerge() {
        localSync(completion:{_ in})
    }
}
