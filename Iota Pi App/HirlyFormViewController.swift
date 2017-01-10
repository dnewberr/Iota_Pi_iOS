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

class FormTableViewController: UITableViewController, SelectNomineeDelegate, VotingServiceDelegate {
    @IBOutlet weak var hirlyNomReasonText: UITextView!
    @IBOutlet weak var topicDescriptionLabel: UILabel!
    @IBOutlet weak var nomineeNameLabel: UILabel!
    
    let votingService = VotingService()
    
    var chosenUser: User?
    var currentTopic: VotingTopic!
    var headerTitles = ["Topic", "Nominee", "Reason"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hirlyNomReasonText.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        hirlyNomReasonText.layer.borderWidth = 1.0
        hirlyNomReasonText.layer.cornerRadius = 5
        
        votingService.votingServiceDelegate = self
        votingService.fetchHirlyTopic()
    }
    
    func updateUI(topic: VotingTopic) {
        self.currentTopic = topic
        self.headerTitles[0] = self.currentTopic.summary
        self.topicDescriptionLabel.text = self.currentTopic.description
        
        self.tableView.reloadData()
    }
    
    func confirmVote() {
        SCLAlertView().showSuccess("Success!", subTitle: "Nomination submitted.")
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func denyVote(isHirly: Bool) {
        SCLAlertView().showError("Cannot Submit Vote", subTitle: "You've already submitted a HIRLy nomination.")
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func noCurrentVote(isHirly: Bool) {
        SCLAlertView().showError("Error", subTitle: "There is currently no active HIRLy vote.")
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func submitVote() {
        if self.nomineeNameLabel.text == "-" {
            SCLAlertView().showError("Error", subTitle: "Please choose a brother to nominate.")
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
}

class HirlyFormViewController: UIViewController {
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var formContainer: UIView!
    var formTableViewController: FormTableViewController!
    
    @IBAction func submitForm(_ sender: AnyObject) {
        self.formTableViewController.submitVote()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "hirlyFormSegue" {
            formTableViewController = segue.destination as? FormTableViewController
        }
    }
}

