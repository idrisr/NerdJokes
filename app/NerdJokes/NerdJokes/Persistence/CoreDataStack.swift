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
    var persistentContainer: NSPersistentContainer
    var parentContext: NSManagedObjectContext
    var clientContext: NSManagedObjectContext
    var syncContext: NSManagedObjectContext
    
    init(completion: (()->())? = nil) {
        persistentContainer = NSPersistentContainer(name: "NerdJokes")
        self.parentContext = persistentContainer.viewContext
        clientContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        clientContext.parent = parentContext
        syncContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        syncContext.parent = parentContext
        
        persistentContainer.loadPersistentStores() { description, error in
            if let error = error {
                fatalError("Cannot load persistent store \(error)")
            }
        }
    }
    
    func save(childContext: NSManagedObjectContext) throws {
        try childContext.save()
        try parentContext.save()
    }
}
