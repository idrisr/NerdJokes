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
    var lastSyncSecondsSince1970: Double
    
    required init(persistence: JokePersistenceService, network: JokeNetworkService) {
        self.persistence = persistence
        self.network = network
        lastSyncSecondsSince1970 = UserDefaults.standard.double(forKey: AppConstants.Keys.kLastSyncSecondsSince1970)
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
    
    func processChange(joke: JokeAPIItem) {
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
    
    func getMostRecentModificationType(joke: JokeAPIItem) -> ModificationType {
        if joke.updatedTime > joke.createdTime && joke.updatedTime > joke.deletedTime {
            return .updated
        } else if joke.createdTime > joke.deletedTime {
            return .created
        } else {
            return .deleted
        }
    }
    
    func getChangesFromNetwork(completion: @escaping ([JokeAPIItem])->()) {
        let lastSyncDate = Int(lastSyncSecondsSince1970)
        network.get { jokes in
        let jokesToChange = jokes.filter({ joke in
            return
                joke.createdTime > lastSyncDate ||
                joke.deletedTime > lastSyncDate ||
                joke.updatedTime > lastSyncDate
            })
            completion(jokesToChange)
        }
    }
    
    func insertFromLocal(joke: JokeAPIItem) {
        Joke.from(jokeAPIItem: joke, context: persistence.coreDataStack.clientContext)
    }
}
