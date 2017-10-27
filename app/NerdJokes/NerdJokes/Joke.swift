//
//  Joke.swift
//  NerdJokes
//
//  Created by Id Raja on 10/26/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import UIKit
import Alamofire

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

extension Joke {
    func save(completionHandler: @escaping (Result<Joke>) -> Void) {
        let fields = self.toJSON()
        Alamofire.request(JokeRouter.create(fields))
            .responseJSON { response in
                // handle response
        }
    }

    private class func jokeFromResponse(response: DataResponse<Any>) -> Result<Joke> {
        guard response.result.error == nil else {
            // got an error in getting the data, need to handle it
            print(response.result.error!)
            return .failure(response.result.error!)
        }

        guard let json = response.result.value as? [String: Any] else {
            print("didnt get json object as JSON from API")
            return .failure(BackendError.objectSerialization(reason:
            "Did not get JSON dictionary in response" ))
        }

        // turn JSON in to Joke object
        guard let joke = Joke(json: json) else {
            return .failure(BackendError.objectSerialization(reason:
            "Could not create Joke object from JSO}"
            ))
        }

        return .success(joke)
    }

    func toJSON() -> [String: Any] {
        var json = [String: Any]()
        json["setup"] = setup
        if let id = id {
            json["id"] = id
        }
        json["punchline"] = punchline
        json["votes"] = votes
        json["created_time"] = created_time
        json["updated_time"] = updated_time
        json["deleted_time"] = deleted_time
        json["deleted_flag"] = deleted_flag
        return json
    }

    class func jokeById(id: Int, completionHandler: @escaping (Result<Joke>) -> Void) {
        Alamofire.request(JokeRouter.get(id))
            .responseJSON { (response: DataResponse<Any>) in
                // check for errors from responseJSON
                guard response.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /jokes/\(id)")
                    print(response.error!)
                    completionHandler(.failure(response.result.error!))
                    return
                }

                // turn JSON in to Joke object
                guard let json = response.value as? [String: Any] else {
                    print("didn't get joke object as JSON from API")
                    completionHandler(.failure(BackendError.objectSerialization(reason: "Did not get a JSON dictionary in response")))
                    return
                }

                guard let joke = Joke(json: json) else {
                    completionHandler(.failure(BackendError.objectSerialization(reason: "Could not create Joke object from JSON")))
                    return
                }

                completionHandler(.success(joke))
        }
    }

    convenience init?(json: [String: Any]) {
        guard
            let setup = json["setup"] as? String,
            let punchline = json["punchline"] as? String, let votes = json["votes"] as? Int,
            let created_time = json["created_time"] as? Int,
            let updated_time = json["updated_time"] as? Int,
            let deleted_time = json["deleted_time"] as? Int,
            let deleted_flag = json["deleted_flag"] as? Bool
            else {
                return nil
        }

        let idValue = json["id"] as? Int
        self.init( id: idValue, setup: setup, punchline: punchline, votes: votes, created_time: created_time, updated_time: updated_time, deleted_time: deleted_time, deleted_flag: deleted_flag)
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
        return "id:\(id ?? -1) setup: \(setup)\n punchline: \(punchline)"
    }
}
