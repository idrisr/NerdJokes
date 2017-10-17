//
//  Resources.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/10/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation

enum ResourceType {
    case getAll
    case getOne
    case delete
    case add
    case update
}

struct GetAllJokesResource: ApiResource {
    var methodPath: String = "/jokes"
    var resourceType: ResourceType = .getAll
    var httpMethod: NJHTTPMethod = .get
    func makeModel(data: Data) -> [JokeAPIItem] {
        guard let model = try? JSONDecoder().decode(Array<JokeAPIItem>.self, from: data) else {
            return []
        }
        return model
    }
}

struct GetSingleJokeResource: ApiResourceWithID {
    var id: ID
    var resourceType: ResourceType = .getOne
    var httpMethod: NJHTTPMethod = .get
    var methodPath: String {
        return methodPath()
    }

    func makeModel(data: Data) -> JokeAPIItem? {
        guard let model = try? JSONDecoder().decode(JokeAPIItem.self, from: data) else {
            return nil
        }
        return model
    }
    
    init(id: ID) {
        self.id = id
    }
}

struct DeleteSingleJokeResource: ApiResourceWithID {
    var id: ID
    var resourceType: ResourceType = .delete
    var httpMethod: NJHTTPMethod = .delete

    var methodPath: String {
        return methodPath()
    }
    func makeModel(data: Data) -> StatusAPIItem? {
        guard let model = try? JSONDecoder().decode(StatusAPIItem.self, from: data) else {
            return nil
        }
        return model
    }
    
    init(id: ID) {
        self.id = id
    }
}

struct AddJokeResource: ApiResource {
    var methodPath: String = "/"
    var resourceType: ResourceType = .add
    var httpMethod: NJHTTPMethod = .post
    
    func makeModel(data: Data) -> JokeAPIItem? {
        guard let model = try? JSONDecoder().decode(JokeAPIItem.self, from: data) else {
            return nil
        }
        return model
    }
}

struct UpdateJokeResource: ApiResourceWithID {
    var id: ID
    var resourceType: ResourceType = .update
    var httpMethod: NJHTTPMethod = .put
    
    var methodPath: String {
        return methodPath()
    }
    func makeModel(data: Data) -> JokeAPIItem? {
        guard let model = try? JSONDecoder().decode(JokeAPIItem.self, from: data) else {
            return nil
        }
        return model
    }
    
    init(id: ID) {
        self.id = id
    }
}
