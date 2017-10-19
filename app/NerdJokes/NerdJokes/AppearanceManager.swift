//
//  AppearanceManager.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/17/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import UIKit

class AppearanceManager {
    enum Theme: Int {
        case light = 0
        case dark
        
        var navigationBarBackgroundColor: UIColor {
            switch self {
            case .dark:
                return UIColor.black.withAlphaComponent(0.5)
            case .light:
                return UIColor(red:0.39, green:0.38, blue:0.67, alpha:0.8)
                
            }
        }
        
        var bodyTextColor: UIColor {
            switch self {
            case .light:
                return UIColor(red:0.11, green:0.12, blue:0.20, alpha:1.00)
            case .dark:
                return .white
            }
        }
        
        var navigationBarTextColor: UIColor {
            return .white
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .light:
                return .white
            case .dark:
                return UIColor(red:0.11, green:0.12, blue:0.20, alpha:1.00)
            }
        }
        
        var buttonColor: UIColor {
            switch self {
            case .light:
                return UIColor(red:0.39, green:0.38, blue:0.67, alpha:1.00)
            case .dark:
                return .white
            }
        }
        
        var name: String {
            switch self {
            case .dark:
                return NSLocalizedString("Dark", comment: "")
            case .light:
                return NSLocalizedString("Light", comment: "")
            }
        }
        
        var statusBarStyle: UIStatusBarStyle {
            switch self {
            case .dark:
                return .lightContent
            case .light:
                return .default
            }
        }
    }

    static func setupTheme(theme: Theme) {
        UILabel.appearance().textColor = theme.bodyTextColor
        
        UITableView.appearance().backgroundColor = theme.backgroundColor
        UITableViewCell.appearance().backgroundColor = theme.backgroundColor
        
        UINavigationBar.appearance().barTintColor = theme.navigationBarBackgroundColor
        UIToolbar.appearance().barTintColor = theme.navigationBarBackgroundColor
        
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: theme.navigationBarTextColor], for: .normal)
        UIBarButtonItem.appearance().tintColor = theme.navigationBarTextColor
        UILabel.appearance(whenContainedInInstancesOf: [UIToolbar.self]).textColor = .white
        
        UINavigationBar.appearance().tintColor = theme.buttonColor
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: theme.navigationBarTextColor]
        
        UIApplication.shared.statusBarStyle = theme.statusBarStyle
    }
}

