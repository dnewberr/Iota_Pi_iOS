//
//  RosterDetailViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/18/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import SCLAlertView

class RosterDetailTableViewController: UITableViewController, RosterServiceDelegate {
    var currentBrotherId: String!
    var editableDetails = [String]()
    var editableTitles = [String]()
    var changedInfo = [String : String]()
    var rosterService = RosterService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.refreshControl?.addTarget(self, action: #selector(ValidateUsersTableViewController.refresh), for: UIControlEvents.valueChanged)
        
        self.editableDetails = (RosterManager.sharedInstance.brothersMap[self.currentBrotherId]?.getArrayOfDetails())!
        self.editableTitles = (RosterManager.sharedInstance.brothersMap[self.currentBrotherId]?.toArrayOfEditableInfo())!
        self.rosterService.rosterServiceDelegate = self
    }
    
    func refresh() {
        self.editableTitles.removeAll()
        self.editableTitles = (RosterManager.sharedInstance.brothersMap[self.currentBrotherId]?.toArrayOfEditableInfo())!
        
        self.tableView.reloadData()
        
        if let isRefreshing = self.refreshControl?.isRefreshing {
            if isRefreshing {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editableDetails.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rosterDetailCell", for: indexPath)
        
        cell.textLabel!.text = self.editableTitles[indexPath.row]
        cell.detailTextLabel!.text = self.editableDetails[indexPath.row]
        
        return cell
    }
    
    public func updateUI() {
        self.refresh()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if RosterManager.sharedInstance.currentUserCanEditRoster() || self.currentBrotherId == RosterManager.sharedInstance.currentUserId {
            let cell = tableView.cellForRow(at: indexPath)!
            
            let editRosterInfo = SCLAlertView()
            let editableInfo = editRosterInfo.addTextField(cell.detailTextLabel!.text)
            editableInfo.text = cell.textLabel?.text
            editableInfo.autocapitalizationType = .none
            editableInfo.autocorrectionType = .no
            
            editRosterInfo.showEdit("Edit Roster Info", subTitle: cell.detailTextLabel!.text!).setDismissBlock {
                if let detail = cell.detailTextLabel?.text, let value = editableInfo.text {
                    self.updateData(key: detail, value: value)
                }
            }
        }
    }
    
    func updateData(key: String, value: String) {
        let curUser = RosterManager.sharedInstance.brothersMap[self.currentBrotherId]!
        let newValue = value.isEmpty ? "N/A" : value
        
        switch key {
            case "Nickname":
                curUser.nickname = newValue
                self.rosterService.pushBrotherDetail(brotherId: self.currentBrotherId, key: "nickname", value: newValue)
            case "Class":
                curUser.educationClass = newValue
                self.rosterService.pushBrotherDetail(brotherId: self.currentBrotherId, key: "class", value: newValue)
            case "Section":
                curUser.section = newValue
                self.rosterService.pushBrotherDetail(brotherId: self.currentBrotherId, key: "section", value: newValue)
            case "Birthday":
                curUser.birthday = newValue
                self.rosterService.pushBrotherDetail(brotherId: self.currentBrotherId, key: "birthday", value: newValue)
            case "Slo Address":
                curUser.sloAddress = newValue
                self.rosterService.pushBrotherDetail(brotherId: self.currentBrotherId, key: "sloAddress", value: newValue)
            case "Major":
                curUser.major = newValue
                self.rosterService.pushBrotherDetail(brotherId: self.currentBrotherId, key: "major", value: newValue)
            case "Expected Graduation":
                curUser.expectedGrad = newValue
                self.rosterService.pushBrotherDetail(brotherId: self.currentBrotherId, key: "expectedGrad", value: newValue)
            default: return
        }
    }
    
    // unnecessary delegate functions
    public func sendCurrentBrotherValidation(isValidated: Bool!) {}
    public func sendMap(map: [String : User]) {}
}

class RosterDetailViewController: UIViewController, RosterServiceDelegate {
    let rosterService = RosterService()
    var currentBrotherId: String!
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var deleteCurrentUserButton: UIBarButtonItem!
    
    
    @IBAction func deleteCurrentUser(_ sender: AnyObject) {
        self.rosterService.markUserForDeletion(uid: self.currentBrotherId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rosterService.rosterServiceDelegate = self
        
        let currentBrother = RosterManager.sharedInstance.brothersMap[self.currentBrotherId]!
        self.numberLabel.text = String(currentBrother.rosterNumber)
        self.statusLabel.text = currentBrother.status.rawValue
        self.title = currentBrother.firstname + " " + currentBrother.lastname
        
        if !RosterManager.sharedInstance.currentUserCanCreateUser()
            || self.currentBrotherId == RosterManager.sharedInstance.currentUserId { //can't delete yourself
            self.deleteCurrentUserButton.isEnabled = false
            self.deleteCurrentUserButton.tintColor = UIColor.clear
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rosterDetaiListSegue" {
            let destination = segue.destination as! RosterDetailTableViewController
            destination.currentBrotherId = self.currentBrotherId
        }
    }
    
    public func updateUI() {
        _ = self.navigationController!.popViewController(animated: true)
    }
    
    // unnecessary delegate functions
    public func sendCurrentBrotherValidation(isValidated: Bool!) {}
    public func sendMap(map: [String : User]) {}
}
