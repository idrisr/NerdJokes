//
//  JokeNetworkRequest.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/10/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation

class JokeNetworkRequest<Resource: ApiResource> {
    let resource: Resource
    init(resource: Resource) {
        self.resource = resource
    }
}

extension JokeNetworkRequest: NetworkRequest {
    func decode(_ data: Data) -> Resource.Model? {
        return resource.makeModel(data: data)
    }
}

