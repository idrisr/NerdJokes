//
//  CoreDataStack.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/10/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStack {
    lazy var parentContext: NSManagedObjectContext = {
       return persistentContainer.viewContext
    }()
    
    lazy var clientContext: NSManagedObjectContext = {
        let clientContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        clientContext.parent = parentContext
        return clientContext
    }()
    
    lazy var syncContext: NSManagedObjectContext = {
        let syncContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        syncContext.parent = parentContext
        return syncContext
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NerdJokes")
        container.loadPersistentStores() { description, error in
            if let error = error {
                fatalError("Cannot load persistent store \(error)")
            }
            print("loaded persistent stores!")
        }
        return container
    }()
    
    func save(childContext: NSManagedObjectContext) throws {
        try childContext.save()
    }
}
