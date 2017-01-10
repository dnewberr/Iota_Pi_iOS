//
//  VotingViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/16/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class VotingViewController: UIViewController, VotingServiceDelegate {
    let votingService = VotingService()
    var currentHirly: VotingTopic!
    var currentVote: VotingTopic!
    
    @IBOutlet weak var currentVoteButton: UIButton!
    @IBOutlet weak var hirlyButton: UIButton!
    @IBAction func createVote(_ sender: AnyObject) {
        let voteCreator = SCLAlertView()
        voteCreator.addButton("HIRLy", action: {
            self.showCreationForm(isSessionCodeRequired: false)
        })
        voteCreator.addButton("Current Vote", action: {
            self.showCreationForm(isSessionCodeRequired: true)
        })
        
        voteCreator.showEdit("Create New Voting Topic", subTitle: "Note that when a new topic is created, the currently open one closes.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hirlyButton.setTitleColor(UIColor.gray, for: UIControlState.disabled)
        
        self.currentVoteButton.setTitleColor(UIColor.gray, for: UIControlState.disabled)
        
        votingService.votingServiceDelegate = self
        votingService.fetchHirlyTopic()
        votingService.fetchCurrentVote()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showCreationForm(isSessionCodeRequired: Bool) {
        let creationForm = SCLAlertView()
        let summaryTextField = creationForm.addTextField("Summary")
        let descriptionTextView = creationForm.addTextView()
        
        creationForm.showEdit("Create New Topic", subTitle: "").setDismissBlock {
            if let summary = summaryTextField.text, let description = descriptionTextView.text {
                if summary.isEmpty || description.isEmpty {
                    SCLAlertView().showError("Invalid Topic", subTitle: "Please submit a summary and descriptin for the new topic.")
                } else {
                    self.pushVotingTopic(summary: summary, description: description, isSessionCodeRequired: isSessionCodeRequired)
                }
            }
        }
    }
    
    public func pushVotingTopic(summary: String, description: String, isSessionCodeRequired: Bool) {
        let newTopic = VotingTopic(summary: summary, description: description, isSessionCodeRequired: isSessionCodeRequired)
        //print(String(format: "[%d]NEW TOPIC:: title - [%s] desc - [%s]", newTopic.getId(), newTopic.summary, newTopic.description))
        let refString = isSessionCodeRequired ? "CurrentVote" : "HIRLy"
        let ref = FIRDatabase.database().reference().child("Voting").child(refString).child(newTopic.getId())
        
        ref.setValue(newTopic.toFirebaseObject())
    }
    
    func updateUI(topic: VotingTopic) {
        if topic.sessionCode.isEmpty {
            self.currentHirly = topic
        } else {
            self.currentVote = topic
            SCLAlertView().showInfo(topic.summary, subTitle: topic.description +  " ; " + topic.sessionCode)
        }
    }
    
    func confirmVote() {}
    func noCurrentVote(isHirly: Bool) {
        if isHirly {
            self.hirlyButton.isEnabled = false
        } else {
            self.currentVoteButton.isEnabled = false
        }
    }
    
    func denyVote(isHirly: Bool) {
        if isHirly {
            self.hirlyButton.isEnabled = false
        } else {
            self.currentVoteButton.isEnabled = false
        }
    }
}
