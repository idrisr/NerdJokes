//
//  JokeTableViewCell.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/13/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import UIKit

class JokeTableViewCell: UITableViewCell {

    @IBOutlet weak var setupLabel: UILabel!
    @IBOutlet weak var punchlineLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    
    func configure(joke: Joke) {
        setupLabel.text = joke.setup
        punchlineLabel.text = joke.punchline
        votesLabel.text = joke.votes.stringValue
    }
}
