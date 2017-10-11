//
//  Sequence+Find.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/11/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation

public extension Sequence {
    func find(predicate: (Iterator.Element) throws -> Bool) rethrows -> Iterator.Element? {
        for element in self {
            if try predicate(element) {
                return element
            }
        }
        return nil
    }
}
