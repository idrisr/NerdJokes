//
//  JokesMasterTableViewEnum.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/16/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import UIKit

enum JokesMasterTableViewEnum: Int, TableViewEnum {
    case joke = 0
    
    static var registrationCells = [JokesMasterTableViewEnum.joke]

    var cellIdentifier: String {
        return "\(JokeTableViewCell.self)"
    }
    
    var height: CGFloat {
        return 100
    }
    
    var name: String {
        return "Jokes"
    }
}
