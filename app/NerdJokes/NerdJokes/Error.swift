//
//  Error.swift
//  NerdJokes
//
//  Created by Id Raja on 10/26/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation

enum BackendError: Error {
    case objectSerialization(reason: String)
}
