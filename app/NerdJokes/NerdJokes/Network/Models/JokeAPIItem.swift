//
//  JokeAPIItem.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/10/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation

struct ID: Codable {
    let value: Int
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

extension ID {
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        self.init(value: value)
    }
}


struct JokeAPIItem: Codable {
    var serverID: ID?
    var setup: String
    var punchline: String
    var votes: Int
    
    var createdTime: Double
    var createdUser: String?
    var updatedTime: Double?
    var updatedUser: String?
    var deletedTime: Double?
    var deletedUser: String?
    
    var deletedFlag: Int //Bool
    
    enum CodingKeys: String, CodingKey {
        case serverID = "id"
        case setup
        case punchline
        case votes
        
        case createdTime = "created_time"
        case createdUser = "created_user"
        case updatedTime = "updated_time"
        case updatedUser = "updated_user"
        case deletedTime = "deleted_time"
        case deletedUser = "deleted_user"
        
        case deletedFlag = "deleted_flag"
    }
}
