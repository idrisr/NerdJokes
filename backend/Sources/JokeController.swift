//
//  NoteController.swift
//  NerdNote
//
//  Created by Nicholas Lash on 10/4/17.
//
//

import Foundation
import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

class JokeController {
    var routes: [Route] {
        return [
            Route(method: .get, uri: "/jokes/test/now", handler: test), // this route is for testing only
            Route(method: .get, uri: "/jokes", handler: getAll),
            Route(method: .post, uri: "/jokes", handler: addNote),
            Route(method: .get, uri: "/jokes/{id}", handler: getByID),
            Route(method: .put, uri: "/jokes/{id}", handler: update),
            Route(method: .delete, uri: "/jokes/{id}", handler: delete),
        ]
    }
    
    func getAll(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try JokeAPI.sharedInstance.all()
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            showError(response: response, message: "Error handling request: \(error)")
        }
    }
    
    func addNote(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try JokeAPI.sharedInstance.new(json: request.postBodyString)
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            showError(response: response, message: "Error handling request: \(error)")
        }

    }

    func getByID(request: HTTPRequest, response: HTTPResponse) {
        guard let id = getID(request: request) else {
            showError(response: response, message: "Invalid ID", status: .badRequest)
            return
        }
        
        do {
            let joke = try Joke.get(id: id)
            
            guard !joke.isEmpty else {
                showError(response: response, message: "ID \(id) does not exist", status: .badRequest)
                return
            }
            
            let json = try joke.asDictionary().jsonEncodedString()
            
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            showError(response: response, message: "Error handling request: \(error)")
        }
    }
    
    func update(request: HTTPRequest, response: HTTPResponse) {
        guard let id = getID(request: request) else {
            showError(response: response, message: "Invalid ID")
            return
        }
        
        do {
            let json = try JokeAPI.sharedInstance.update(id: id, json: request.postBodyString)
            
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            showError(response: response, message: "Error handling request: \(error)")
        }

    }
    
    func delete(request: HTTPRequest, response: HTTPResponse) {
        guard let id = getID(request: request) else {
            showError(response: response, message: "Invalid ID", status: .badRequest)
            return
        }
        
        do {
            let json = try JokeAPI.sharedInstance.delete(id: id)
            
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            showError(response: response, message: "Error handling request: \(error)")
        }
    }
    
    func test(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try JokeAPI.sharedInstance.test()
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            showError(response: response, message: "Error handling request: \(error)")
        }
    }
    
    func getID(request: HTTPRequest) -> Int? {
        guard
            let idString = request.urlVariables["id"],
            let id = Int(idString) else {
                return nil
        }
        return id
    }
    
    func showError(response: HTTPResponse, message: String, status: HTTPResponseStatus = .internalServerError) {
        do {
            try response.setBody(json: ["error": message])
                .setHeader(.contentType, value: "application/json")
                .completed(status: status)
        } catch {
            print("Can't show error message \(error)")
        }
    }
}
