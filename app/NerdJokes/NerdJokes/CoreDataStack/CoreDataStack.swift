//
//  CoreDataStack.swift
//  NerdJokes
//
//  Created by Id Raja on 10/30/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataStack {
    private let modelName: String

    init(modelName: String) {
        self.modelName = modelName
    }

    private lazy var syncContext: NSManagedObjectContext = {
            return container.newBackgroundContext()
    }()

    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }

    lazy var container : NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { (storeDescription: NSPersistentStoreDescription, error: Error?) in
            if let error = error {
                fatalError("yo you got issues")
            }
        }
        return container
    }()
}
