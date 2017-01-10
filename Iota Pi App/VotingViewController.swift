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
    var denyHirly = false
    var denyCurrent = false
    
    @IBOutlet weak var currentVoteCodeLabel: UILabel!
    @IBOutlet weak var currentVoteButton: UIButton!
    @IBAction func viewHirly(_ sender: AnyObject) {
        if denyHirly {
            SCLAlertView().showError("Cannot Submit Vote", subTitle: "You've already submitted a HIRLy nomination.")
             _ = self.navigationController?.popViewController(animated: true)
        } else {
            self.performSegue(withIdentifier: "showHirlySegue", sender: self)
        }
    }
    @IBOutlet weak var hirlyButton: UIButton!
    @IBAction func viewCurrent(_ sender: AnyObject) {
        if denyCurrent {
            SCLAlertView().showError("Cannot Submit Vote", subTitle: "You've already voted on the open topic.")
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            self.performSegue(withIdentifier: "showCurrentVoteSegue", sender: self)
        }
    }
    
    @IBAction func createVote(_ sender: AnyObject) {
        let voteCreator = SCLAlertView()
        voteCreator.addButton("HIRLy", action: {
            self.showCreationForm(isSessionCodeRequired: false)
        })
        voteCreator.addButton("Current Vote", action: {
            self.showCreationForm(isSessionCodeRequired: true)
        })
        
        voteCreator.showEdit("Create New Vote", subTitle: "Note that when a new topic is created, the current one closes.")
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
                    SCLAlertView().showSuccess("Create New Topic", subTitle: "A new voting topic was successfully created!")
                }
            }
        }
    }
    
    // TODO MOVE TO SERVICE
    public func pushVotingTopic(summary: String, description: String, isSessionCodeRequired: Bool) {
        let newTopic = VotingTopic(summary: summary, description: description, isSessionCodeRequired: isSessionCodeRequired)
        let refString = isSessionCodeRequired ? "CurrentVote" : "HIRLy"
        let ref = FIRDatabase.database().reference().child("Voting").child(refString).child(newTopic.getId())
        
        ref.setValue(newTopic.toFirebaseObject())
    }
    
    func updateUI(topic: VotingTopic) {
        if topic.sessionCode.isEmpty {
            self.currentHirly = topic
            self.hirlyButton.isEnabled = true
        } else {
            self.currentVote = topic
            self.currentVoteButton.isEnabled = true
            self.currentVoteCodeLabel.text = topic.sessionCode
        }
    }
    
    func confirmVote() {}
    
    func noCurrentVote(isHirly: Bool) {
        if isHirly {
            self.hirlyButton.isEnabled = false
        } else {
            self.currentVoteButton.isEnabled = false
            self.currentVoteCodeLabel.text = ""
        }
    }
    
    func denyVote(isHirly: Bool) {
        print("IN DENY")
        
        if isHirly {
            self.denyHirly = true
        } else {
            self.denyCurrent = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHirlySegue" {
            let destination = segue.destination as! HirlyFormViewController
            destination.hirlyTopic = self.currentHirly
        } else if segue.identifier == "showCurrentVoteSegue" {
            let destination = segue.destination as! CurrentVoteViewController
        }
    }
}
