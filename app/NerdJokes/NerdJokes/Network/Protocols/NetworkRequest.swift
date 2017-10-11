//
//  NetworkRequest.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/10/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation

protocol NetworkRequest: class {
    associatedtype Model
    func decode(_ data: Data) -> Model?
}

extension NetworkRequest {
    func makeRequest(urlRequest: URLRequest, completion: @escaping (Model?, Error?) -> Void) {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForResource = AppConstants.kTimeoutInterval
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: urlRequest, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data else {
                print("\(String(describing: error)) \(String(describing: urlRequest.url))")
                completion(nil, error)
                return
            }
            
            guard let model = self.decode(data) else {
                print("Error decoding data: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                return
            }
            
            completion (model, error)
        })
        task.resume()
    }
}
