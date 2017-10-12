//
//  TestJokeNetworkRequest.swift
//  NerdJokesTests
//
//  Created by Nicholas Lash on 10/12/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation
import NerdJokes
@testable import NerdJokes

class TestJokeNetworkRequest<Resource: ApiResource> {
    let resource: Resource
    init(resource: Resource) {
        self.resource = resource
    }
}

extension TestJokeNetworkRequest: TestNetworkRequest, URLRequestComposable {
    func decode(_ data: Data) -> Resource.Model? {
        let oneItemFilePath = Bundle.main.path(forResource: "single_joke", ofType: "json")!
        let oneItemURL = URL(fileURLWithPath: oneItemFilePath)
        let oneItemData = try! Data(contentsOf: oneItemURL, options: .uncached)
        
        let allItemsFilePath = Bundle.main.path(forResource: "all_jokes", ofType: "json")!
        let allItemsURL = URL(fileURLWithPath: allItemsFilePath)
        let allItemsData = try! Data(contentsOf: allItemsURL, options: .uncached)
        
        let statusFilePath = Bundle.main.path(forResource: "status", ofType: "json")!
        let statusURL = URL(fileURLWithPath: statusFilePath)
        let statusData = try! Data(contentsOf: statusURL, options: .uncached)
        
        switch resource.resourceType {
        case .getAll:
            return resource.makeModel(data: allItemsData)
        case .add, .update, .getOne:
            return resource.makeModel(data: oneItemData)
        case .delete:
            return resource.makeModel(data: statusData)
        }
    }
}

protocol TestNetworkRequest: class {
    associatedtype Model
    func decode(_ data: Data) -> Model?
}

extension TestNetworkRequest {
    func makeRequest(urlRequest: URLRequest, completion: @escaping (Model, Error?) -> Void) {
        guard let model = self.decode(Data()) else {
            print("Error decoding data.")
            return
        }
        
        completion (model, nil)
    }
}

