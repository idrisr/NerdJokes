//
//  PostAPIItem.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/19/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation

struct PostAPIItem: Codable {
    let serverID: ID
    
    enum CodingKeys: String, CodingKey {
        case serverID = "id"
    }
}
