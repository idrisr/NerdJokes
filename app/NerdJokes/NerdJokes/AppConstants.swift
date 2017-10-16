//
//  AppConstants.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/10/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import UIKit

enum ModificationType {
    case created
    case updated
    case deleted
}

enum ModificationState {
    case dirty
    case clean
}

enum ModifyAction {
    case add
    case edit
}

enum NJHTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

struct AppConstants {
    static let kBaseURL = "http://localhost:8080"
    static let kTimeoutInterval = 1.0
    
    struct Keys {
        static let kLastSyncSecondsSince1970 = "lastSyncSecondsSince1970"
    }
    
    static var uuidString: String {
        return UIDevice.current.identifierForVendor!.uuidString + NSUUID().uuidString
    }
}

struct LastSyncedSetting {
    static var value: Double {
        get {
            return UserDefaults.standard.double(forKey: AppConstants.Keys.kLastSyncSecondsSince1970)
        }
        set(newValue) {
            UserDefaults.standard.set(Date(), forKey: AppConstants.Keys.kLastSyncSecondsSince1970)
        }
    }
}
