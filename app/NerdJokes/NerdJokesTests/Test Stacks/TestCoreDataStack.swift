//
//  TestCoreDataStack.swift
//  NerdJokesTests
//
//  Created by Nicholas Lash on 10/12/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation
@testable import NerdJokes
import CoreData

class TestCoreDataStack: CoreDataStack {
    override lazy var persistentContainer: NSPersistentContainer = {
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        
        let container = NSPersistentContainer(name: "NerdJokes")
        container.persistentStoreDescriptions = [persistentStoreDescription]
        container.loadPersistentStores() { description, error in
            if let error = error {
                fatalError("Cannot load persistent store \(error)")
            }
            print("loaded persistent stores!")
        }
        return container
    }()
}
