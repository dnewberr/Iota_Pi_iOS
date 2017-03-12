//
//  HirlyFormViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/17/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class FormTableViewController: UITableViewController, SelectNomineeDelegate, VotingServiceDelegate, UITextViewDelegate {
    @IBOutlet weak var hirlyNomReasonText: UITextView!
    @IBOutlet weak var topicDescriptionLabel: UILabel!
    @IBOutlet weak var nomineeNameLabel: UILabel!
    
    let votingService = VotingService()
    
    var chosenUser: User?
    var currentTopic: VotingTopic!
    var headerTitles = ["Topic", "Nominee", "Reason"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.votingService.votingServiceDelegate = self
        
        hirlyNomReasonText.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        hirlyNomReasonText.layer.borderWidth = 1.0
        hirlyNomReasonText.layer.cornerRadius = 5
        
        self.headerTitles[0] = self.currentTopic.summary
        self.topicDescriptionLabel.text = self.currentTopic.description
    }
    
    // Closes keyboard when tapped outside textfields
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func confirmVote() {
        SCLAlertView().showSuccess("Success!", subTitle: "Nomination submitted.").setDismissBlock {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func submitVote() {
        if self.nomineeNameLabel.text == "-" || self.hirlyNomReasonText.text!.trim().isEmpty {
            SCLAlertView().showError("Error", subTitle: "Please choose a brother and write the reason you wish to nominate them.")
        } else {
            self.votingService.submitHirlyNom(topic: self.currentTopic, nomBroId: (self.chosenUser?.userId)!, reason: self.hirlyNomReasonText.text)
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitles[section]
    }
    
    func saveSelection(chosenNominee: User?) {
        self.chosenUser = chosenNominee
        
        if let user = self.chosenUser {
            self.nomineeNameLabel.text = user.firstname + " " + user.lastname
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nomineeSelectionSegue" {
            let destination = segue.destination as! HirlyNomineeSelectionViewController
            destination.nomineeDelegate = self
        }
    }
    
    func delete() {
        self.votingService.deleteVote(id: self.currentTopic.getId(), topics: [], isHirly: true, isShown: true)
    }
    
    
    func showMessage(message: String) {
        SCLAlertView().showTitle(
            "Delete Vote",
            subTitle: message,
            duration: 0.0,
            completeText: "Okay",
            style: .notice,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF).setDismissBlock {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    // delegate unnecessary methods
    func updateUI(topic: VotingTopic) {}
    func denyVote(isHirly: Bool, topic: VotingTopic?) {}
    func noCurrentVote(isHirly: Bool) {}
    func sendArchivedTopics(topics: [VotingTopic]) {}
}

class HirlyFormViewController: UIViewController {
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var formContainer: UIView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var hirlyTopic: VotingTopic!
    var formTableViewController: FormTableViewController!
    
    @IBAction func deleteVote(_ sender: Any) {
        let deleteVoteAlert = SCLAlertView()
        deleteVoteAlert.addButton("Delete") {
            self.formTableViewController.delete()
        }
        
        deleteVoteAlert.showTitle(
            "Delete HIRLy Vote",
            subTitle: "Are you sure you wish to delete this vote? Its results will not be displayed in the archives.",
            duration: 0.0,
            completeText: "Cancel",
            style: .info,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF)
    }
    
    @IBAction func submitForm(_ sender: AnyObject) {
        self.formTableViewController.submitVote()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !RosterManager.sharedInstance.currentUserCanCreateHirly() {
            self.deleteButton.isEnabled = false
            self.deleteButton.tintColor = UIColor.clear
        }
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "hirlyFormSegue" {
            formTableViewController = segue.destination as? FormTableViewController
            formTableViewController.currentTopic = hirlyTopic
        }
    }
}

