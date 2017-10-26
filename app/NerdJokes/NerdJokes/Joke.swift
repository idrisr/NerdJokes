//
//  Joke.swift
//  NerdJokes
//
//  Created by Id Raja on 10/26/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import UIKit

class Joke {
    var id: Int?
    var setup: String
    var punchline: String
    var votes: Int
    var created_time: Int
    var updated_time: Int
    var deleted_time: Int
    var deleted_flag: Bool

    required init?(id: Int?, setup: String, punchline: String, votes: Int, created_time: Int,
                   updated_time: Int, deleted_time: Int, deleted_flag: Bool) {
        self.id = id
        self.setup = setup
        self.punchline = punchline
        self.votes = votes
        self.created_time = created_time
        self.updated_time = updated_time
        self.deleted_time = deleted_time
        self.deleted_flag = deleted_flag
    }
}

extension Joke: CustomStringConvertible {
    public var description: String {
        guard let id = id else {
            return "no id"
        }

        return "\(id)"
    }
}

extension Joke: CustomDebugStringConvertible {
    public var debugDescription: String {
        // todo
        return "do me"
    }
}
