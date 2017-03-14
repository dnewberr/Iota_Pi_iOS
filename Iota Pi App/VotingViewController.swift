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

class VotingViewController: UIViewController, VotingServiceDelegate, UITextFieldDelegate {
    let MAX_CURRENT_SUMMARY_LENGTH = 18
    let MAX_HIRLY_SUMMARY_LENGTH = 40
    let votingService = VotingService()
    var currentHirly: VotingTopic!
    var currentVote: VotingTopic!
    var denyHirly = false
    var denyCurrent = false
    var summaryMaxLength = Int.max
    
    @IBOutlet weak var archivedCurrentVoteButton: UIButton!
    @IBOutlet weak var archiveVoteButton: UIBarButtonItem!
    @IBOutlet weak var createVoteButton: UIBarButtonItem!
    @IBOutlet weak var currentVoteCodeLabel: UILabel!
    @IBOutlet weak var currentVoteButton: UIButton!
    
    @IBAction func archiveVote(_ sender: Any) {
        let archiveAlert = SCLAlertView()
        
        if self.currentHirly != nil && RosterManager.sharedInstance.currentUserCanCreateHirly() {
            archiveAlert.addButton("HIRLy") {
                self.votingService.archive(id: self.currentHirly.getId(), isHirly: true, isAuto: false)
                self.currentHirly = nil
            }
        }
        
        if self.currentVote != nil && RosterManager.sharedInstance.currentUserCanCreateVote() {
            archiveAlert.addButton("Current Vote") {
                self.votingService.archive(id: self.currentVote.getId(), isHirly: false, isAuto: false)
                self.currentVote = nil
            }
        }
        
        archiveAlert.showTitle(
            "Archive Vote",
            subTitle: "Which vote would you like to archive?",
            duration: 0.0,
            completeText: "Cancel",
            style: .info,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF)

    }
    
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
                self.currentVote.summary,
                subTitle: self.currentVote.description,
                duration: 0.0,
                completeText: "Cancel",
                style: .info,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF)
        }
    }
    
    func submitVote(vote: String, code: String?) {
        let confirmAlert = SCLAlertView()
        confirmAlert.addButton("Confirm") {
            if let codeEntered = code {
                if codeEntered == self.currentVote.sessionCode {
                    self.votingService.submitCurrentVote(topic: self.currentVote, vote: vote)
                } else {
                    SCLAlertView().showError("Error", subTitle: "Please the correct session code.")
                }
            } else {
                SCLAlertView().showError("Error", subTitle: "Please the correct session code.")
            }
        }
        
        confirmAlert.showTitle(
            "Submit Vote",
            subTitle: "Are you sure you wish to vote \"\(vote)\" on this topic?",
            duration: 0.0,
            completeText: "Cancel",
            style: .edit,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF)
        
    }
    
    @IBAction func createVote(_ sender: AnyObject) {
        let voteCreator = SCLAlertView()
        
        if RosterManager.sharedInstance.currentUserCanCreateHirly() {
            voteCreator.addButton("HIRLy", action: {
                self.summaryMaxLength = self.MAX_HIRLY_SUMMARY_LENGTH
                self.showCreationForm(isHirly: true)
            })
        }
        
        if RosterManager.sharedInstance.currentUserCanCreateVote() {
            voteCreator.addButton("Current Vote", action: {
                self.summaryMaxLength = self.MAX_CURRENT_SUMMARY_LENGTH
                self.showCreationForm(isHirly: false)
            })
        }
        
        voteCreator.showTitle(
            "Create New Vote",
            subTitle: "Note that when a new topic is created, the current one automatically archives.",
            duration: 0.0,
            completeText: "Cancel",
            style: .edit,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hirlyButton.setTitleColor(UIColor.gray, for: .disabled)
        self.hirlyButton.setBackgroundColor(color: UIColor.white, forState: .disabled)
        self.currentVoteButton.setTitleColor(UIColor.gray, for: .disabled)
        self.currentVoteButton.setBackgroundColor(color: UIColor.white, forState: .disabled)
        
        self.managePermissions()
        
        // If the user isn't Active or Associate, they cannot vote
        if RosterManager.sharedInstance.currentUserAdmin != .NoVoting {
            votingService.votingServiceDelegate = self
            votingService.fetchHirlyTopic()
            votingService.fetchCurrentVote()
        } else {
            self.hirlyButton.isEnabled = false
            self.currentVoteButton.isEnabled = false
        }
    }
    
    // helps to manage the many views dependent on admin priviledges and presence of votes
    func managePermissions() {
        self.hirlyButton.isEnabled = self.currentHirly != nil
        self.currentVoteButton.isEnabled = self.currentVote != nil
        
        if !RosterManager.sharedInstance.currentUserCanCreateHirly()
            && !RosterManager.sharedInstance.currentUserCanCreateVote() {
            // Hide ability to create a vote
            self.createVoteButton.isEnabled = false
            self.createVoteButton.tintColor = UIColor.clear
            
            // Hide ability to see archived current votes, hide current vote label
            self.archivedCurrentVoteButton.isHidden = true
            self.currentVoteCodeLabel.isHidden = true
            
            // Hide ability to archive a vote
            self.archiveVoteButton.isEnabled = false
            self.archiveVoteButton.tintColor = UIColor.clear
        } else {
            // Show create vote button
            self.createVoteButton.isEnabled = true
            self.createVoteButton.tintColor = nil
            
            // if they can create a current vote, DON'T hide the archive current vote button/code label
            self.archivedCurrentVoteButton.isHidden = !RosterManager.sharedInstance.currentUserCanCreateVote()
            self.currentVoteCodeLabel.isHidden = !RosterManager.sharedInstance.currentUserCanCreateVote()
            
            // if they can create that vote type and there's an open vote, let them
            if (self.currentHirly != nil && RosterManager.sharedInstance.currentUserCanCreateHirly())
                || (self.currentVote != nil && RosterManager.sharedInstance.currentUserCanCreateVote()) {
                self.archiveVoteButton.isEnabled = true
                self.archiveVoteButton.tintColor = nil
            } else {
                self.archiveVoteButton.isEnabled = false
                self.archiveVoteButton.tintColor = UIColor.clear
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.managePermissions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func showCreationForm(isHirly: Bool) {
        let creationForm = SCLAlertView()
        let summaryTextField = creationForm.addTextField("Summary")
        summaryTextField.delegate = self
        
        let descriptionTextView = creationForm.addTextView()
        
        creationForm.addButton("Create") {
            if let summary = summaryTextField.text, let description = descriptionTextView.text {
                if summary.trim().isEmpty || description.trim().isEmpty {
                    SCLAlertView().showError("Invalid Topic", subTitle: "Please submit a summary and description for the new topic.")
                } else {
                    if isHirly && self.currentHirly != nil {
                        self.votingService.archive(id: self.currentHirly.getId(), isHirly: isHirly, isAuto: true)
                    } else if !isHirly && self.currentVote != nil {
                        self.votingService.archive(id: self.currentVote.getId(), isHirly: isHirly, isAuto: true)
                    }
                    self.votingService.pushVotingTopic(summary: summary, description: description, isHirly: isHirly)
                }
            }
        }
        
        creationForm.showTitle(
            "Create New Topic",
            subTitle: "",
            duration: 0.0,
            completeText: "Cancel",
            style: .edit,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF)
    }
    
    // keeps text length at max
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        let newLength = text.characters.count + string.characters.count - range.length
        if newLength >= self.summaryMaxLength {
            textField.deleteBackward()
            return false
        }
        return true
    }
    
    func updateUI(topic: VotingTopic) {
        if topic.sessionCode.isEmpty {
            self.currentHirly = topic
            self.denyHirly = false
        } else {
            self.currentVote = topic
            self.denyCurrent = false
            
            if RosterManager.sharedInstance.currentUserCanCreateVote() {
                self.currentVoteCodeLabel.text = "Current Vote Session Code: " + topic.sessionCode
            }
        }
        
        self.managePermissions()
    }
    
    func confirmVote() {
        SCLAlertView().showSuccess("Success!", subTitle: "Vote submitted.").setDismissBlock {
            self.denyCurrent = true
        }
    }
    
    func noCurrentVote(isHirly: Bool) {
        if isHirly {
            self.currentHirly = nil
        } else {
            self.currentVoteCodeLabel.text = ""
            self.currentVote = nil
        }
        
        self.managePermissions()
    }
    
    func denyVote(isHirly: Bool, topic: VotingTopic?) {
        if isHirly {
            self.currentHirly = topic
            self.denyHirly = true
        } else {
            self.currentVote = topic
            self.denyCurrent = true
            
            if let topic = topic {
                self.currentVoteCodeLabel.text = "Current Vote Session Code: " + topic.sessionCode
            }
        }
        
        self.managePermissions()
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

    
    func showMessage(message: String, title: String, isError: Bool) {
        if isError {
            SCLAlertView().showError(title, subTitle: message).setDismissBlock {
                self.managePermissions()
            }
        } else {
            SCLAlertView().showTitle(
                title,
                subTitle: message,
                duration: 0.0,
                completeText: "Okay",
                style: .notice,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF).setDismissBlock {
                    self.managePermissions()
            }
        }
    }
}
