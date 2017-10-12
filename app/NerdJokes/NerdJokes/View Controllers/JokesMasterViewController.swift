//
//  JokesMasterViewController.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/10/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import UIKit
import CoreData

class JokesMasterViewController: UIViewController {
    // MARK: - instance vars
    var jokeService: JokeService!
    @objc var fetchedResultsController: NSFetchedResultsController<Joke>!
    
    // MARK: - outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        let fetchRequest: NSFetchRequest<Joke> = Joke.fetchRequest()
        let sortByDate = NSSortDescriptor(key: "createdTime", ascending: false)
        
        fetchRequest.sortDescriptors = [sortByDate]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: jokeService.persistence.coreDataStack.clientContext, sectionNameKeyPath: nil, cacheName: "joke")
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("cannot fetch objects")
        }
        
        tableView.dataSource = self
        fetchedResultsController.delegate = self
    }
}

// MARK: UITableViewDataSource
extension JokesMasterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sectionInfo = fetchedResultsController.sections else {
            return 0
        }
        
        return sectionInfo.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //MARK: -  change this later
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = fetchedResultsController.object(at: indexPath).setup
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension JokesMasterViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            print("update to TBD")
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
}
