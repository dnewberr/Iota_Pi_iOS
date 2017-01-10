//
//  CurrentVoteViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/17/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class CurrentVoteViewController: UIViewController, VotingServiceDelegate {
    @IBOutlet weak var sessionCodeText: UITextField!
    @IBAction func yesVote(_ sender: AnyObject) {
        self.submitVote(vote: "yes")
    }
    @IBAction func abstainVote(_ sender: AnyObject) {
        self.submitVote(vote: "abstain")
    }
    @IBAction func noVote(_ sender: AnyObject) {
        self.submitVote(vote: "no")
    }
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    var currentTopic: VotingTopic!
    let votingService = VotingService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.summaryLabel.text = self.currentTopic.summary
        self.descriptionLabel.text = self.currentTopic.description
        
        self.votingService.votingServiceDelegate = self
    }
    
    func submitVote(vote: String) {
        if let codeEntered = self.sessionCodeText.text {
            if (codeEntered == self.currentTopic.sessionCode) {
                self.votingService.submitCurrentVote(topic: self.currentTopic, vote: vote)
            } else {
                SCLAlertView().showError("Error", subTitle: "Please the correct session code.")
            }
        } else {
            SCLAlertView().showError("Error", subTitle: "Please the correct session code.")
        }
    }
    
    func updateUI(topic: VotingTopic) {}
    
    func confirmVote() {
        SCLAlertView().showSuccess("Success!", subTitle: "Vote submitted.").setDismissBlock {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func denyVote(isHirly: Bool) {}
    
    func noCurrentVote(isHirly: Bool) {}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
