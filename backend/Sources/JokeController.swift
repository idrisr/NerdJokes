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

class NoteController {
    var routes: [Route] {
        return [
            Route(method: .get, uri: "/jokes/test", handler: test),
            Route(method: .get, uri: "/jokes", handler: getAll),
            Route(method: .post, uri: "/jokes", handler: addNote),
            Route(method: .get, uri: "/jokes/{id}", handler: getByID),
            Route(method: .put, uri: "/notes/{id}", handler: update),
            Route(method: .delete, uri: "/notes/{id}", handler: delete),
        ]
    }
    
    func getAll(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try NoteAPI.sharedInstance.all()
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
            let json = try NoteAPI.sharedInstance.new(json: request.postBodyString)
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
            let json = try Note.get(id: id).asDictionary().jsonEncodedString()
            
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
            let json = try NoteAPI.sharedInstance.update(id: id, json: request.postBodyString)
            
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
            let json = try NoteAPI.sharedInstance.delete(id: id)
            
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
            let json = try NoteAPI.sharedInstance.test()
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
