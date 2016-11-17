//
//  HirlyFormViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/17/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import Firebase

class FormTableViewController: UITableViewController, SelectNomineeDelegate {
    @IBOutlet weak var hirlyNomReasonText: UITextView!
    @IBOutlet weak var topicDescriptionLabel: UILabel!
    @IBOutlet weak var nomineeNameLabel: UILabel!
    
    var chosenUser: User?
    var headerTitles = ["Topic", "Nominee", "Reason"]
    var currentTopic: VotingTopic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hirlyNomReasonText.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        hirlyNomReasonText.layer.borderWidth = 1.0
        hirlyNomReasonText.layer.cornerRadius = 5
        
        let ref = FIRDatabase.database().reference().child("Voting").child("HIRLy")
        
        ref.observeSingleEvent(of: .value, with:{ (snapshot) -> Void in
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                let topic = VotingTopic(dict: dict, expiration: key)
                
                if (!topic.archived) {
                    self.currentTopic = topic
                }
            }
            
            self.headerTitles[0] = self.currentTopic.summary
            self.topicDescriptionLabel.text = self.currentTopic.description
            
            self.tableView.reloadData()
        })
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
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
