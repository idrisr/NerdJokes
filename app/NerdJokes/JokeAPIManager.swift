//
//  JokeAPIManager.swift
//  NerdJokes
//
//  Created by Id Raja on 10/26/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation
import Alamofire

class JokeAPIManager {
    static let sharedInstance = JokeAPIManager()

    func printPublicJokes() {
        Alamofire.request(JokeRouter.getAll())
            .responseString { response in
                if let receivedString = response.result.value {
                    print(receivedString)
                }
        }
    }
}
