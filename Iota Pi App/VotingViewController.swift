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
    
    @IBOutlet weak var archivedCurrentVoteButton: UIButton!
    @IBOutlet weak var createVoteButton: UIBarButtonItem!
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
        } else if self.currentVote != nil {
            let currentVote = SCLAlertView()
            let voteCodeTextField = currentVote.addTextField()
            voteCodeTextField.placeholder = "Vote Code"
            voteCodeTextField.autocapitalizationType = .none
            voteCodeTextField.autocorrectionType = .no
            
            currentVote.addButton("Yes") {
                self.submitVote(vote: "yes", code: voteCodeTextField.text)
            }
            currentVote.addButton("No") {
                self.submitVote(vote: "no", code: voteCodeTextField.text)
            }
            currentVote.addButton("Abstain") {
                self.submitVote(vote: "abstain", code: voteCodeTextField.text)
            }
            
            currentVote.showTitle(
                "Current Vote",
                subTitle: self.currentVote.description,
                duration: 0.0,
                completeText: "Vote",
                style: .info,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF)
        }
    }
    
    func submitVote(vote: String, code: String?) {
        if let codeEntered = code {
            if (codeEntered == self.currentVote.sessionCode) {
                self.votingService.submitCurrentVote(topic: self.currentVote, vote: vote)
            } else {
                SCLAlertView().showError("Error", subTitle: "Please the correct session code.")
            }
        } else {
            SCLAlertView().showError("Error", subTitle: "Please the correct session code.")
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
        
        voteCreator.showTitle(
            "Create New Vote",
            subTitle: "Note that when a new topic is created, the current one closes.",
            duration: 0.0,
            completeText: "Cancel",
            style: .edit,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (RosterManager.sharedInstance.currentUserCanCreateVote()) {
            self.createVoteButton.isEnabled = true
            self.createVoteButton.tintColor = nil
            self.currentVoteCodeLabel.isHidden = false
            self.archivedCurrentVoteButton.isHidden = false
        } else {
            self.createVoteButton.isEnabled = false
            self.createVoteButton.tintColor = UIColor.clear
            self.currentVoteCodeLabel.isHidden = true
            self.archivedCurrentVoteButton.isHidden = true
        }
        
        self.hirlyButton.setTitleColor(UIColor.gray, for: UIControlState.disabled)
        self.currentVoteButton.setTitleColor(UIColor.gray, for: UIControlState.disabled)
        self.hirlyButton.isEnabled = false
        self.currentVoteButton.isEnabled = false
        
        votingService.votingServiceDelegate = self
        votingService.fetchHirlyTopic()
        votingService.fetchCurrentVote()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func showCreationForm(isSessionCodeRequired: Bool) {
        let creationForm = SCLAlertView()
        let summaryTextField = creationForm.addTextField("Summary")
        let descriptionTextView = creationForm.addTextView()
        
        creationForm.showTitle(
            "Create New Topic",
            subTitle: "",
            duration: 0.0,
            completeText: "Done",
            style: .edit,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF).setDismissBlock {
            if let summary = summaryTextField.text, let description = descriptionTextView.text {
                if summary.trim().isEmpty || description.trim().isEmpty {
                    SCLAlertView().showError("Invalid Topic", subTitle: "Please submit a summary and description for the new topic.")
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
            self.denyHirly = false
        } else {
            self.currentVote = topic
            self.currentVoteButton.isEnabled = true
            self.currentVoteCodeLabel.text = topic.sessionCode
            self.denyCurrent = false
        }
    }
    
    func confirmVote() {
        SCLAlertView().showSuccess("Success!", subTitle: "Vote submitted.")
        
        self.currentVoteButton.isEnabled = false
        self.denyCurrent = true
    }
    
    func noCurrentVote(isHirly: Bool) {
        if isHirly {
            self.hirlyButton.isEnabled = false
        } else {
            self.currentVoteButton.isEnabled = false
            self.currentVoteCodeLabel.text = ""
        }
    }
    
    func denyVote(isHirly: Bool, topic: VotingTopic?) {
        if isHirly {
            self.denyHirly = true
            self.hirlyButton.isEnabled = true
        } else {
            self.denyCurrent = true
            
            if let topic = topic {
                self.currentVoteCodeLabel.text = topic.sessionCode
            }
            self.currentVoteButton.isEnabled = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHirlySegue" {
            let destination = segue.destination as! HirlyFormViewController
            destination.hirlyTopic = self.currentHirly
        }
        
        if segue.identifier == "hirlyArchivedSegue" {
            let destination = segue.destination as! ArchivedVoteTableViewController
            destination.isHirly = true
        }
        
        if segue.identifier == "currentArchivedSegue" {
            let destination = segue.destination as! ArchivedVoteTableViewController
            destination.isHirly = false
        }
    }
    
    
    // unnecessary delegate methods
    func sendArchivedTopics(topics: [VotingTopic]) {}
    func error(message: String) {}
}
