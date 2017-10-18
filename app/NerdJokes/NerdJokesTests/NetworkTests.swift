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
    
    func testGetOne() {
        let resource = GetSingleJokeResource(id: ID(value: 12345))
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
        
        guard let strJokeResult = jokeResult else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(strJokeResult.clientID?.value, "ueao-uaeotsuoha-uetoahut")
        XCTAssertEqual(strJokeResult.updatedUser, "Rachel")
        
    }
    
    func testGetAll() {
        let resource = GetAllJokesResource()
        var urlRequest = URLRequest(url: resource.url)
        var jokeResults = [JokeAPIItem]()
        urlRequest.httpMethod = resource.httpMethod.rawValue
        let requestExpectation = expectation(description: "Request expectation")
        
        TestJokeNetworkRequest(resource: resource).makeRequest(urlRequest: urlRequest) { jokes, error in
            jokeResults = jokes

            requestExpectation.fulfill()
        }
        
        wait(for: [requestExpectation], timeout: 3.0)
        XCTAssertEqual(jokeResults.count, 4)
        XCTAssertEqual(jokeResults.last!.clientID?.value, "ueao-uaeotsuoha-uetoahuteuaetsuaoteunenuoa")
    }
    
    
    func testDelete() {
        let resource = DeleteSingleJokeResource(id: ID(value: "12345"))
        var urlRequest = URLRequest(url: resource.url)
        var statusResult: StatusAPIItem?
        urlRequest.httpMethod = resource.httpMethod.rawValue
        let requestExpectation = expectation(description: "Request expectation")
        
        TestJokeNetworkRequest(resource: resource).makeRequest(urlRequest: urlRequest) { status, error in
            guard let status = status else {
                XCTFail()
                requestExpectation.fulfill()
                return
            }
            
            statusResult = status
            
            requestExpectation.fulfill()
        }
        
        wait(for: [requestExpectation], timeout: 3.0)
        
        guard let strStatusResult = statusResult else {
            return
        }
        XCTAssertEqual(strStatusResult.message, "Succesfully deleted item.")
        XCTAssertEqual(strStatusResult.success, true)
    }
    
    func testUpdate() {
        let resource = UpdateJokeResource(id: ID(value: "12345"))
        var urlRequest = URLRequest(url: resource.url)
        var jokeResult: JokeAPIItem?
        urlRequest.httpMethod = resource.httpMethod.rawValue
        let requestExpectation = expectation(description: "Request expectation")
        
        TestJokeNetworkRequest(resource: resource).makeRequest(urlRequest: urlRequest) { joke, error in
            guard let joke = joke else {
                XCTFail()
                requestExpectation.fulfill()
                return
            }
            
            jokeResult = joke
            requestExpectation.fulfill()
        }
        
        wait(for: [requestExpectation], timeout: 3.0)
        
        guard let strJokeResult = jokeResult else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(strJokeResult.clientID?.value, "ueao-uaeotsuoha-uetoahut")
        XCTAssertEqual(strJokeResult.updatedUser, "Rachel")
    }
    
    func testAdd() {
        let resource = AddJokeResource()
        var urlRequest = URLRequest(url: resource.url)
        var jokeResult: JokeAPIItem?
        urlRequest.httpMethod = resource.httpMethod.rawValue
        let requestExpectation = expectation(description: "Request expectation")
        
        TestJokeNetworkRequest(resource: resource).makeRequest(urlRequest: urlRequest) { joke, error in
            guard let joke = joke else {
                XCTFail()
                requestExpectation.fulfill()
                return
            }
            
            jokeResult = joke
            requestExpectation.fulfill()
        }
        
        wait(for: [requestExpectation], timeout: 3.0)
        
        guard let strJokeResult = jokeResult else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(strJokeResult.clientID?.value, "ueao-uaeotsuoha-uetoahut")
        XCTAssertEqual(strJokeResult.updatedUser, "Rachel")
    }
}
