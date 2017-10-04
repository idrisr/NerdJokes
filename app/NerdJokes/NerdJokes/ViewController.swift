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
            if let response = response {
                print(response)
            }

            if let error = error {
                print(error)
            }
        }
        
        task.resume()
    }
}
