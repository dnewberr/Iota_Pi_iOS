//
//  ValidateUsersTableViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 2/14/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit
import SCLAlertView

class ValidateUsersTableViewController: UITableViewController, RosterServiceDelegate {
    let rosterService = RosterService()
    var invalidUsers = [User]()
    var uidsToVerify = [String]()
    
    @IBAction func submitValidationRequest(_ sender: AnyObject) {
        let validateAlertView = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        validateAlertView.addButton("Validate") {
            self.rosterService.validateBrothers(uids: self.uidsToVerify)
        }
        validateAlertView.addButton("Cancel") {}
        validateAlertView.showWarning("Validate Users", subTitle: "Are you sure you wish to validate the selected users?")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("❤️❤️❤️❤️❤️ TO VALIDATE:: \(RosterManager.sharedInstance.brothersToValidate)")
        print("❤️❤️❤️❤️❤️ VALID:: \(RosterManager.sharedInstance.brothersMap)")
        
        self.uidsToVerify.removeAll()
        self.invalidUsers.removeAll()
        self.invalidUsers = Array(RosterManager.sharedInstance.brothersToValidate.values)
        
        self.refreshControl?.addTarget(self, action: #selector(ValidateUsersTableViewController.refresh), for: UIControlEvents.valueChanged)

        self.rosterService.rosterServiceDelegate = self
        self.tableView.allowsMultipleSelection = true
    }

    func refresh() {
        RosterManager.sharedInstance.populateRoster()
        self.uidsToVerify.removeAll()
        self.invalidUsers.removeAll()
        self.invalidUsers = Array(RosterManager.sharedInstance.brothersToValidate.values)
        self.tableView.reloadData()
        
        if (self.refreshControl?.isRefreshing)! {
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.invalidUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "invalidUserCell", for: indexPath)
        
        cell.textLabel?.text = self.invalidUsers[indexPath.row].firstname + " " + self.invalidUsers[indexPath.row].lastname

        cell.accessoryType = cell.isSelected ? .checkmark : .none
        cell.selectionStyle = .none // to prevent cells from being "highlighted"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        uidsToVerify.append(self.invalidUsers[indexPath.row].userId)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        
        if let uidIndex = uidsToVerify.index(of: self.invalidUsers[indexPath.row].userId) {
            uidsToVerify.remove(at: uidIndex)
        }
    }
    
    func updateUI() {
        SCLAlertView().showSuccess("Validate Users", subTitle: "Successfully validated the requested users!").setDismissBlock {
            self.refresh()
        }
    }
    
    //unnecessary delegate method
    func sendMap(map: [String : User]) {}
}
