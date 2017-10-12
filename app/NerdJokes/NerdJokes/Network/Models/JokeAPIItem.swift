//
//  JokeAPIItem.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/10/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation

struct ID: Codable {
    let value: String
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

extension ID {
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        self.init(value: value)
    }
}


struct JokeAPIItem: Codable {
    var clientID: ID?
    var setup: String
    var punchline: String
    var votes: Int
    
    var createdTime: Int
    var createdUser: String
    var updatedTime: Int
    var updatedUser: String
    var deletedTime: Int
    var deletedUser: String
    
    var deletedFlag: Bool
}
