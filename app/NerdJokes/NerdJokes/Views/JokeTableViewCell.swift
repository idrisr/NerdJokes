//
//  JokeTableViewCell.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/13/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import UIKit

protocol JokeTableViewCellDelegate {
    func vote(joke: Joke, delta: Int)
}

class JokeTableViewCell: UITableViewCell {
    // MARK: - instance vars
    var delegate: JokeTableViewCellDelegate?
    private var joke: Joke?
    
    // MARK: - outlet
    @IBOutlet weak var setupLabel: UILabel!
    @IBOutlet weak var punchlineLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    
    // MARK: - setup
    func configure(joke: Joke) {
        self.joke = joke
        setupLabel.text = joke.setup
        punchlineLabel.text = joke.punchline
        votesLabel.text = joke.votes.stringValue
    }
    
    // MARK: Actions
    @IBAction func upVote(_ sender: Any) {
        guard let joke = joke else {
            return
        }
        delegate?.vote(joke: joke, delta: 1)
    }
    
    @IBAction func downVote(_ sender: Any) {
        guard let joke = joke else {
            return
        }
        delegate?.vote(joke: joke, delta: -1)
    }
}
