//
//  TodoNetworkService.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/10/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation

protocol URLRequestComposable {
}

extension URLRequestComposable {
    func makeURLRequest(resource: ApiRoute, joke: JokeAPIItem? = nil) -> URLRequest {
        var urlRequest = URLRequest(url: resource.url)
        urlRequest.httpMethod = resource.httpMethod.rawValue
        
        guard let joke = joke else {
            return urlRequest
        }
        
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try! JSONEncoder().encode(joke)
        
        return urlRequest
    }
}

class JokeNetworkService: URLRequestComposable {
    func get(completion: @escaping ([JokeAPIItem])->()) {
        print("get request made")
        let resource = GetAllJokesResource()
        let urlRequest = makeURLRequest(resource: resource)
        
        JokeNetworkRequest(resource: resource).makeRequest(urlRequest: urlRequest, completion: { items, error in
            if let error = error {
                print(error)
            }
            
            completion(items ?? [])
        })
    }
    
    func get(id: ID, completion: ((JokeAPIItem?)->())? = nil) {
        print("getbyid request made")
        let resource = GetSingleJokeResource(id: id)
        let urlRequest = makeURLRequest(resource: resource)
        
        JokeNetworkRequest(resource: resource).makeRequest(urlRequest: urlRequest, completion: { item, error in
            if let error = error {
                print(error)
            }

            completion?(item ?? nil)
        })
    }
    
    func add(joke: JokeAPIItem, completion: ((Bool)->())? = nil) {
        print("Add request made")
        let resource = AddJokeResource()
        let urlRequest = makeURLRequest(resource: resource, joke: joke)
        
        JokeNetworkRequest(resource: resource).makeRequest(urlRequest: urlRequest, completion: { result, error in
            guard
                error == nil,
                let _ = result else {
                    print("ERROR adding joke \(String(describing: error?.localizedDescription))")
                    completion?(false)
                    return
            }
            completion?(true)
        })
    }
    
    func update(joke: JokeAPIItem, completion: ((Bool)->())? = nil) {
        print("update request made")
        guard let clientID = joke.clientID else {
            completion?(false)
            return
        }
        let resource = UpdateJokeResource(id: clientID)
        let urlRequest = makeURLRequest(resource: resource, joke: joke)
        
        JokeNetworkRequest(resource: resource).makeRequest(urlRequest: urlRequest, completion: { results, error in
            guard
                error == nil,
                let _ = results else {
                    print("ERROR updating joke \(String(describing: error?.localizedDescription))")
                    completion?(false)
                    return
            }
            completion?(true)
        })
    }
    
    func delete(id: ID, completion: ((Bool)->())? = nil) {
        print("delete request made")
        let resource = DeleteSingleJokeResource(id: id)
        let urlRequest = makeURLRequest(resource: resource)
        
        JokeNetworkRequest(resource: resource).makeRequest(urlRequest: urlRequest, completion: { result, error in
            guard
                error == nil,
                let _ = result else {
                    print("error deleting joke \(String(describing: error?.localizedDescription))")
                    completion?(false)
                    return
            }
            completion?(true)
        })
    }
    
    
}
