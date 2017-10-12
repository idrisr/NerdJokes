//
//  PersistenceTests.swift
//  NerdJokesTests
//
//  Created by Nicholas Lash on 10/11/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import XCTest
import CoreData
@testable import NerdJokes


class PersistenceTests: XCTestCase {
    var persistence: JokePersistenceService!
    var coreDataStack: CoreDataStack!
    override func setUp() {
        super.setUp()
        
        coreDataStack = TestCoreDataStack()
        persistence = JokePersistenceService(coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        super.tearDown()
        coreDataStack = nil
        persistence = nil
    }
    
    func testAddItem() {
        let joke = Joke.insert(setup: "Why did the chicken cross the road?", punchline: "To get to the other side!", votes: 399, context: persistence.coreDataStack.clientContext)
        try! persistence.coreDataStack.save(childContext: persistence.coreDataStack.clientContext)
        guard let clientID = joke.clientID else {
            fatalError()
        }
        guard let item = persistence.get(id: clientID, context: persistence.coreDataStack.clientContext) else {
            XCTFail("Cannot get item")
            return
        }
        
        guard let itemFromParent = persistence.get(id: clientID, context: persistence.coreDataStack.parentContext) else {
            XCTFail("Cannot get item")
            return
        }
        
        XCTAssertEqual(item.setup, "Why did the chicken cross the road?")
        XCTAssertEqual(itemFromParent.setup, "Why did the chicken cross the road?")
    }
    
    func testDeleteItem() {
        let joke = Joke.insert(setup: "Why did the chicken cross the road?", punchline: "To get to the other side!", votes: 399, context: persistence.coreDataStack.clientContext)
        let id = joke.clientID
        try! persistence.coreDataStack.save(childContext: persistence.coreDataStack.clientContext)
        persistence.delete(joke: joke, context: persistence.coreDataStack.clientContext)
        guard let item = persistence.get(id: id!, context: persistence.coreDataStack.clientContext) else {
            XCTFail("Cannot get item")
            return
        }
        guard let itemFromParent = persistence.get(id: id!, context: persistence.coreDataStack.parentContext) else {
            XCTFail("Cannot get item")
            return
        }
        
        XCTAssertEqual(item.deletedFlag, true)
        XCTAssertEqual(itemFromParent.deletedFlag, true)
    }
    
    func testUpdateItem() {
        let joke = Joke.insert(setup: "Why did the chicken cross the road?", punchline: "To get to the other side!", votes: 399, context: persistence.coreDataStack.clientContext)
        let clientID = joke.clientID!
        try! persistence.coreDataStack.save(childContext: persistence.coreDataStack.clientContext)
        guard let item = persistence.get(id: clientID, context: persistence.coreDataStack.clientContext) else {
            XCTFail("Cannot get item")
            return
        }
        item.punchline = "stupidity"
        try! persistence.coreDataStack.clientContext.save()
        
        guard let refetchedItem = persistence.get(id: clientID, context: persistence.coreDataStack.clientContext) else {
            XCTFail("Cannot get item")
            return
        }
        
        guard let refetchedItemFromParent = persistence.get(id: clientID, context: persistence.coreDataStack.parentContext) else {
            XCTFail("Cannot get item")
            return
        }
        
        XCTAssertEqual(refetchedItem.punchline, "stupidity")
        XCTAssertEqual(refetchedItemFromParent.punchline, "stupidity")
    }
    
    func testGetAll() {
        let joke1 = Joke.insert(setup: "Why did the chicken cross the road?", punchline: "To get to the other side!", votes: 399, context: persistence.coreDataStack.clientContext)
        let joke2 = Joke.insert(setup: "Why did the animals run?", punchline: "To go to the pizza store!", votes: 399, context: persistence.coreDataStack.clientContext)
        try! persistence.coreDataStack.save(childContext: persistence.coreDataStack.clientContext)
        let jokes = persistence.getAll(context: persistence.coreDataStack.clientContext)
        
        XCTAssertEqual(jokes.count, 2)
        XCTAssertNotNil(jokes.find(predicate: {
            $0.clientID == joke1.clientID
        }))
        XCTAssertNotNil(jokes.find(predicate: {
            $0.clientID == joke2.clientID
        }))
    }
}
