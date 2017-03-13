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
    var invalidUsers = Array(RosterManager.sharedInstance.brothersToValidate.values)
    var uidsToVerify = [String]()
    
    var blurredEffectView: UIVisualEffectView!
    var indicator: UIActivityIndicatorView!
    
    @IBAction func submitValidationRequest(_ sender: AnyObject) {
        let validateAlertView = SCLAlertView()
        
        if uidsToVerify.isEmpty {
            validateAlertView.showTitle(
                "Validate Users",
                subTitle: "Please select at least one user to validate.",
                duration: 0.0,
                completeText: "Okay",
                style: .warning,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF)
        } else {
            self.blurView()
            self.indicator.startAnimating()
            validateAlertView.addButton("Validate") {
                self.rosterService.validateBrothers(uids: self.uidsToVerify)
            }
        
            validateAlertView.showTitle(
                "Validate Users",
                subTitle: "Are you sure you wish to validate the selected users?",
                duration: 0.0,
                completeText: "Cancel",
                style: .warning,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.allowsMultipleSelection = true
        self.rosterService.rosterServiceDelegate = self
        
        self.indicator = Utilities.createActivityIndicator(center: self.parent!.view.center)
        self.parent!.view.addSubview(indicator)
        
        let blurEffect = UIBlurEffect(style: .dark)
        self.blurredEffectView = UIVisualEffectView(effect: blurEffect)
        self.blurredEffectView.frame = self.view.frame
        view.addSubview(self.blurredEffectView)
        self.blurredEffectView.alpha = 0;
        
        self.refreshControl?.addTarget(self, action: #selector(ValidateUsersTableViewController.refresh), for: UIControlEvents.valueChanged)
    }

    //TODO
    func refresh() {
        RosterManager.sharedInstance.populateRoster()
        self.uidsToVerify.removeAll()
        self.invalidUsers.removeAll()
        self.invalidUsers = Array(RosterManager.sharedInstance.brothersToValidate.values)
        if invalidUsers.isEmpty {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            self.tableView.reloadData()
        }
    
        
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let deletePendingUserAlert = SCLAlertView()
            deletePendingUserAlert.addButton("Delete") {
                self.rosterService.markUserForDeletion(uid: self.invalidUsers[indexPath.row].userId)
            }
            
            deletePendingUserAlert.showTitle(
                "Delete User",
                subTitle: "Are you sure you wish to delete this user?",
                duration: 0.0,
                completeText: "Cancel",
                style: .warning,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF)
        }

        return [delete]
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
    
    func blurView() {
        UIView.animate(withDuration: Utilities.ANIMATION_DURATION) {
            self.blurredEffectView.alpha = 1.0
        }
    }
    
    func updateUI(isDeleted: Bool) {
        let message = isDeleted ? "Successfully deleted the selected brother." : "Successfully validated the requested brother(s)!"
        SCLAlertView().showSuccess("Validate Brothers", subTitle: message).setDismissBlock {
            self.indicator.stopAnimating()
            self.blurredEffectView.alpha = 0
            self.blurredEffectView.layer.removeAllAnimations()
            self.refresh()
        }
    }
    
    func error(message: String, autoClose: Bool) {
        if autoClose {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            
            SCLAlertView(appearance: appearance).showError("Error", subTitle: message, duration: 1)
        } else {
            SCLAlertView().showError("Error", subTitle: message)
        }
    }
    
    //unnecessary delegate method
    func sendMap(map: [String : User]) {}
}
