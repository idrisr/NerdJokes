//
//  ViewController.swift
//  NerdJokes
//
//  Created by Id Raja on 10/4/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let todoEndpoint: String = "http://jsonplaceholder.typicode.com/todos/1"

        guard let url = URL(string: todoEndpoint) else {
            print("Error cannot create url")
            return
        }

        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared

        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                return
            }

            guard let responseData = data else {
                print("error did not receive data")
                return
            }

            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("error trying to convert data to JSON")
                    return
                }

                print ("The todo is: " + todo.description)

                guard let todoTitle = todo["title"] as? String else {
                    print("Could not get todo title from JSON")
                    return
                }

                print ("The title is: " + todoTitle)
            } catch let e as NSError {
                print(e.localizedDescription)
            }
        }
        
        task.resume()
    }
}
