//
//  TestNetwork.swift
//  NerdJokesTests
//
//  Created by Nicholas Lash on 10/12/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import XCTest
@testable import NerdJokes

class NetworkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetAll() {
        let resource = GetSingleJokeResource(id: ID(value: "12345"))
        var urlRequest = URLRequest(url: resource.url)
        var jokeResult: JokeAPIItem?
        
        urlRequest.httpMethod = resource.httpMethod.rawValue
        
        let requestExpectation = expectation(description: "Request expectation")
        
       
        TestJokeNetworkRequest(resource: resource).makeRequest(urlRequest: urlRequest) { joke, error in
            guard let joke = joke else {
                requestExpectation.fulfill()
                return
            }
            requestExpectation.fulfill()
            jokeResult = joke
        }
        
        wait(for: [requestExpectation], timeout: 3.0)
        XCTAssertNotNil(jokeResult)
        
    }
    
}
