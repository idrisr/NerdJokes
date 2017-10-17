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
        if UserDefaults.standard.object(forKey: AppConstants.Keys.kTheme) == nil {
            CurrentTheme.value = AppearanceManager.Theme.light.rawValue
        }
        
        AppearanceManager.setupTheme(theme: AppearanceManager.Theme(rawValue: CurrentTheme.value)!)

        guard
            let navigationViewController = window?.rootViewController as? UINavigationController,
            let jokesMasterViewController = navigationViewController.topViewController as? JokesMasterViewController else {
                return true
        }
        
        jokesMasterViewController.jokeService = JokeService(persistence: JokePersistenceService(coreDataStack: CoreDataStack()), network: JokeNetworkService())
        
        
        
        return true
    }
}

