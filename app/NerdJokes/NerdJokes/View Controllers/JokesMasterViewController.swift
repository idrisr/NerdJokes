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
    var context: NSManagedObjectContext!
    @objc var fetchedResultsController: NSFetchedResultsController<Joke>!
    var refreshControl: UIRefreshControl?
    
    var allJokes: [Joke] {
        guard let jokes = fetchedResultsController.fetchedObjects else {
            return []
        }
        return jokes
    }
    
    // MARK: - outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - actions
    @IBAction func didTapAddButton(_ sender: Any) {
        addOrEditJoke(action: .add)
    }
    
    @IBAction func didTapEditButton(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing {
            editButton.title = NSLocalizedString("Done", comment: "")
        } else {
            editButton.title = NSLocalizedString("Edit", comment: "")
        }
    }
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        tableView.separatorStyle = .none
        loadingIndicator.isHidden = false
        setupPullToRefresh()
        jokeService.sync { [weak self] in
            self?.setupFetchResults()
            self?.setupTableView()
            self?.loadingIndicator.isHidden = true
        }
    }
    
    private func setupPullToRefresh() {
        refreshControl = UIRefreshControl()
        guard let refreshControl = refreshControl else {
            return
        }
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(pullToRefreshAction), for: .valueChanged)
        
        tableView.addSubview(refreshControl)
    }
    
    @objc private func pullToRefreshAction() {
         jokeService.sync { [weak self] in
            guard let this = self else {
                return
            }
            
            do {
                try this.fetchedResultsController.performFetch()
            } catch {
                print("cannot fetch items")
            }
            this.refreshControl?.endRefreshing()
        }
    }
    
    private func registerCell(name: String) {
        let cellNib = UINib(nibName: name, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: name)
    }
    
    private func setupFetchResults() {
        context = jokeService.persistence.coreDataStack.clientContext
        let fetchRequest: NSFetchRequest<Joke> = Joke.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "deletedFlag == NO")
        let sortByDate = NSSortDescriptor(key: "createdTime", ascending: false)
        fetchRequest.sortDescriptors = [sortByDate]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "joke")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("cannot fetch objects")
        }
    }
    
    private func setupTableView() {
        JokesMasterTableViewEnum.registrationCells.forEach { section in
            registerCell(name: section.cellIdentifier)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
}

// MARK: UITableViewDataSource
extension JokesMasterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return JokesMasterTableViewEnum.registrationCells.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allJokes.count == 0 {
            tableView.separatorStyle = .none
        } else {
            tableView.separatorStyle = .singleLine
        }
        return allJokes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //MARK: -  change this later
        guard let section = JokesMasterTableViewEnum(rawValue: indexPath.section) else {
            fatalError("incorrect section")
        }
        
        switch section {
        case .joke:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: section.cellIdentifier) as? JokeTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(joke: joke(at: indexPath))
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let isIndexWithinBounds = indexPath.row < allJokes.count
            guard isIndexWithinBounds else {
                return
            }
            
            jokeService.deleteFromLocal(joke: joke(at: indexPath))
            break
        default:
            break
        }
    }
    
    private func joke(at indexPath: IndexPath) -> Joke {
        return fetchedResultsController.object(at: indexPath)
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
            guard
                let indexPath = indexPath,
                let cell = tableView.cellForRow(at: indexPath) else {
                    return
            }
            configure(cell: cell, for: indexPath)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    fileprivate func configure(cell: UITableViewCell, for indexPath: IndexPath?) {
        guard
            let indexPath = indexPath,
            let cell = cell as? JokeTableViewCell else {
                return
        }
        
        let joke = fetchedResultsController.object(at: indexPath)
        cell.configure(joke: joke)
    }
}

extension JokesMasterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addOrEditJoke(action: .edit, joke: fetchedResultsController.object(at: indexPath))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - helper methods
fileprivate extension JokesMasterViewController {
    func addOrEditJoke(action: ModifyAction, joke: Joke? = nil) {
        let alertController = UIAlertController(title: action == .add ? "Add a joke" : "Edit todo", message: "", preferredStyle: .alert)
        
        makeTextFields(alertController: alertController, joke: joke)
        alertController.addAction(makeAddAction(alertController: alertController, action: action, joke: joke))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func makeTextFields(alertController: UIAlertController, joke: Joke?) {
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Setup"
            if let joke = joke {
                textField.text = joke.setup
            }
        })
        alertController.addTextField(configurationHandler:{ textField in
            textField.placeholder = "Punchline"
            if let joke = joke {
                textField.text = joke.punchline
            }
        })
    }
    
    private func makeAddAction(alertController: UIAlertController, action: ModifyAction, joke: Joke?) -> UIAlertAction {
        return UIAlertAction(title: action == .add ? "Add" : "Save", style: .default) { [weak self] _ in
            guard
                let this = self,
                let fields = alertController.textFields,
                let setupField = fields.first,
                let punchlineField = fields.last,
                let setup = setupField.text,
                let punchline = punchlineField.text else {
                    return
            }
            
            switch action {
            case .add:
                this.jokeService.insertIntoLocal(setup: setup, punchline: punchline)
                break
            case .edit:
                guard let joke = joke else {
                    return
                }
                this.jokeService.updateIntoLocal(jokeToUpdate: joke, setup: setup, punchline: punchline)
                break
            }
            do {
                try this.fetchedResultsController.performFetch()
            } catch {
                print("Can't add or modify record \(error.localizedDescription)")
            }
        }
    }
}

extension JokesMasterViewController: JokeTableViewCellDelegate {
    func vote(joke: Joke, delta: Int) {
        let votes = joke.votes.intValue + delta
        jokeService.updateIntoLocal(jokeToUpdate: joke, setup: joke.setup, punchline: joke.punchline, votes: votes)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Can't add or modify record \(error.localizedDescription)")
        }
    }
}
