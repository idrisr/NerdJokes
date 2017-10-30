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
    private let syncContext: NSManagedObjectContext
    private let mainContext: NSManagedObjectContext
    private let name: String

    init(name: String) {
        syncContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.name = name
    }

    lazy var stack: NSPersistentContainer = {
        return NSPersistentContainer(name: name, managedObjectModel: <#T##NSManagedObjectModel#>)
    }()
}
