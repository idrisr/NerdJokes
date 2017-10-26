//
//  JokeRouter.swift
//  NerdJokes
//
//  Created by Id Raja on 10/26/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import Foundation
import Alamofire

enum JokeRouter: URLRequestConvertible {
    static let baseURLString = "http://localhost/"

    case get(Int)
    case getAll
    case create([String: Any])
    case update([String: Any])
    case delete(Int)

    func asURLRequest() throws -> URLRequest {
        // todo implement me
        var method: HTTPMethod {
            switch self {
            case .get:
                return .get
            case .getAll:
                return .get
            case .create:
                return .post
            case .update:
                return .put
            case .delete:
                return .delete
            }
        }

        let url: URL = {
            let relativePath: String

            switch self {
            case .get(let id):
                relativePath = "jokes/\(id)"
            case .getAll:
                relativePath = "jokes"
            case .create:
                relativePath = "jokes"
            case .update(let id):
                relativePath = "jokes/\(id)"
            case .delete(let id):
                relativePath = "jokes/\(id)"
            }

            guard var url = URL(string: JokeRouter.baseURLString) else {
                fatalError("issues with your URL dude")
            }

            url.appendPathComponent(relativePath)
            return url
        }()

        let params: ([String: Any]?) = {
            switch self {
            case .create(let params):
                return (params)
            case .update(let params):
                return (params)
            case .get:
                return nil
            case .getAll:
                return nil
            case .delete:
                return nil
            }
        }()

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        let encoding = JSONEncoding.default
        return try encoding.encode(urlRequest, with: params)
    }
}
