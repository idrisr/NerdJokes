//
//  ApiResource.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/10/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation



protocol ApiResource: ApiRoute {
    associatedtype Model
    
    func makeModel(data: Data) -> Model
}

protocol ApiRoute {
    var methodPath: String { get }
    var httpMethod: NJHTTPMethod { get }
}

extension ApiRoute {
    var url: URL {
        let baseURL = AppConstants.kBaseURL
        let url = baseURL + methodPath
        return URL(string: url)!
    }
}

protocol ApiResourceWithID: ApiResource {
    var id: ID { get set }
}

extension ApiResourceWithID {
    func methodPath() -> String {
        return "/\(id.value)"
    }
}
