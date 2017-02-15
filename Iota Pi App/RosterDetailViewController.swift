//
//  RosterDetailViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/18/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import SCLAlertView

class RosterDetailTableViewCell: UITableViewCell {
    func update(info: String, detail: String) {
        self.detailTextLabel?.text = detail
        self.textLabel?.text = info
    }
}

class RosterDetailTableViewController: UITableViewController, RosterServiceDelegate {
    var currentBrotherId: String!
    var editableDetails = [String]()
    var editableTitles = [String]()
    var changedInfo = [String : String]()
    var rosterService = RosterService()
    
    
//    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.indicator = Utilities.createActivityIndicator(center: self.view.center)
       
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "rosterDetailCell", for: indexPath) as! RosterDetailTableViewCell
        
        cell.update(info: self.editableTitles[indexPath.row], detail: self.editableDetails[indexPath.row])
        
        return cell
    }
    
    public func updateUI() {
        self.refresh()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if RosterManager.sharedInstance.currentUserCanEditRoster() || self.currentBrotherId == RosterManager.sharedInstance.currentUserId {
            let cell = tableView.cellForRow(at: indexPath) as! RosterDetailTableViewCell
            
            let editRosterInfo = SCLAlertView()
            let editableInfo = editRosterInfo.addTextField(cell.detailTextLabel?.text)
            editableInfo.text = cell.textLabel?.text
            
            editRosterInfo.showEdit("Edit Roster Info", subTitle: (cell.detailTextLabel?.text)!).setDismissBlock {
                if let detail = cell.detailTextLabel?.text, let value = editableInfo.text {
                    self.updateData(key: detail, value: value)
                }
            }
        }
    }
    
    func updateData(key: String, value: String) {
        let curUser = RosterManager.sharedInstance.brothersMap[self.currentBrotherId]!
        
        switch key {
            case "Nickname":
                curUser.nickname = value
                self.rosterService.pushBrotherDetail(brotherId: self.currentBrotherId, key: "nickname", value: value)
            case "Class":
                curUser.educationClass = value
                self.rosterService.pushBrotherDetail(brotherId: self.currentBrotherId, key: "class", value: value)
            case "Section":
                curUser.section = value
                self.rosterService.pushBrotherDetail(brotherId: self.currentBrotherId, key: "section", value: value)
            case "Birthday":
                curUser.birthday = value
                self.rosterService.pushBrotherDetail(brotherId: self.currentBrotherId, key: "birthday", value: value)
            case "Slo Address":
                curUser.sloAddress = value
                self.rosterService.pushBrotherDetail(brotherId: self.currentBrotherId, key: "sloAddress", value: value)
            case "Major":
                curUser.major = value
                self.rosterService.pushBrotherDetail(brotherId: self.currentBrotherId, key: "major", value: value)
            case "Expected Graduation":
                curUser.expectedGrad = value
                self.rosterService.pushBrotherDetail(brotherId: self.currentBrotherId, key: "expectedGrad", value: value)
            default: return
        }
    }
    
    //unnecessary
    public func sendCurrentBrotherValidation(isValidated: Bool!) {}
    
    public func sendMap(map: [String : User]) {}

}

class RosterDetailViewController: UIViewController {
    var currentBrotherId: String!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let currentBrother = RosterManager.sharedInstance.brothersMap[self.currentBrotherId]!
        self.numberLabel.text = String(currentBrother.rosterNumber)
        self.statusLabel.text = currentBrother.status.rawValue
        self.title = currentBrother.firstname + " " + currentBrother.lastname
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rosterDetaiListSegue" {
            let destination = segue.destination as! RosterDetailTableViewController
            destination.currentBrotherId = self.currentBrotherId
        }
    }
}
