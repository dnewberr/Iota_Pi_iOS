//
//  CurrentVoteViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/17/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import Firebase

class CurrentVoteViewController: UIViewController, VotingServiceDelegate {
    @IBOutlet weak var sessionCodeText: UITextField!
    @IBAction func yesVote(_ sender: AnyObject) {
    }
    @IBAction func abstainVote(_ sender: AnyObject) {
    }
    @IBAction func noVote(_ sender: AnyObject) {
    }
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    var currentTopic: VotingTopic!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let votingService = VotingService()
        votingService.votingServiceDelegate = self
        votingService.fetchCurrentVote()
    }
    
    func updateUI(topic: VotingTopic) {
        self.currentTopic = topic
        self.summaryLabel.text = self.currentTopic.summary
        self.descriptionLabel.text = self.currentTopic.description
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
