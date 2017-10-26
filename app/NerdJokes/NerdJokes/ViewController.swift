//
//  ViewController.swift
//  NerdJokes
//
//  Created by Id Raja on 10/26/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Joke.jokeById(id: 2) { result in
            if let error = result.error {
                // got an error in getting the data, need to handle it
                print("error calling POST on /jokes/")
                print(error)
                return
            }

            guard let joke = result.value else {
                print("error calling POST on /jokes/. result is nil")
                return
            }

            // success!
            print(joke.description)
            print(joke.setup)
        }
    }
}
