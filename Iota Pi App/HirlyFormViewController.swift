//
//  HirlyFormViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/17/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit

class FormTableViewController: UITableViewController {
    @IBOutlet weak var hirlyNomReasonText: UITextView!
    @IBOutlet weak var topicDescriptionLabel: UILabel!
    @IBOutlet weak var nomineeNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hirlyNomReasonText.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        hirlyNomReasonText.layer.borderWidth = 1.0
        hirlyNomReasonText.layer.cornerRadius = 5
        
        
    }
}

class HirlyFormViewController: UIViewController {
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var formContainer: UIView!
    var chosenUser: User?
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
        /*func saveSelection(chosenNominee: User?) {
         self.chosenUser = chosenNominee
         
         if let user = self.chosenUser {
         self.hirlyNomLabel.text = user.firstname + " " + user.lastname
         } else{
         self.hirlyNomLabel.text = "-"
         }
         }
         
         func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         if (section == 0) {
         return "test??"
         }
         
         return "other"
         }
         
         
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "nomineeSelectionSegue" {
         let destination = segue.destination as! HirlyNomineeSelectionViewController
         destination.nomineeDelegate = self
         }
         }*/


}
