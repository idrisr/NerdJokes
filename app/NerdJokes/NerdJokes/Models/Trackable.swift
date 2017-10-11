//
//  Trackable.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/10/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation
import CoreData

class Trackable: NSManagedObject {
    @NSManaged var createdTime: Date
    @NSManaged var createdUser: String
    
    @NSManaged var updatedTime: Date?
    @NSManaged var updatedUser: String?
    
    @NSManaged var deletedTime: Date?
    @NSManaged var deletedUser: String?
    
    @NSManaged var deletedFlag: Bool
}
