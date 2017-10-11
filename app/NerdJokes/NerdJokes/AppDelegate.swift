//
//  AppDelegate.swift
//  NerdJokes
//
//  Created by Id Raja on 10/4/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        guard let jokesMasterViewController = window?.rootViewController as? JokesMasterViewController else {
            return true
        }
        
        jokesMasterViewController.jokeService = JokeService(persistence: JokePersistenceService(coreDataStack: CoreDataStack()), network: JokeNetworkService())
        
        return true
    }
}

