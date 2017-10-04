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
            Route(method: .get, uri: "/jokes/test/now", handler: test),
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
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func addNote(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try JokeAPI.sharedInstance.new(json: request.postBodyString)
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }

    }

    func getByID(request: HTTPRequest, response: HTTPResponse) {
        guard let id = getID(request: request) else {
            response.setBody(string: "Invalid ID")
                .completed(status: .internalServerError)
            return
        }
        
        do {
            let joke = try Joke.get(id: id)
            
            guard !joke.isEmpty else {
                response.setBody(string: "ID \(id) does not exist")
                    .completed(status: .internalServerError)
                return
            }
            
            let json = try joke.asDictionary().jsonEncodedString()
            
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func update(request: HTTPRequest, response: HTTPResponse) {
        guard let id = getID(request: request) else {
            response.setBody(string: "Invalid ID")
                .completed(status: .internalServerError)
            return
        }
        
        do {
            let json = try JokeAPI.sharedInstance.update(id: id, json: request.postBodyString)
            
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }

    }
    
    func delete(request: HTTPRequest, response: HTTPResponse) {
        guard let id = getID(request: request) else {
            response.setBody(string: "Invalid ID")
                .completed(status: .internalServerError)
            return
        }
        
        do {
            let json = try JokeAPI.sharedInstance.delete(id: id)
            
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func test(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try JokeAPI.sharedInstance.test()
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
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
}
