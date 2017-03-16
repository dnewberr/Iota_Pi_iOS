//
//  MoreTableViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 10/27/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class MoreTableViewController: UITableViewController, LoginServiceDelegate {
    let loginService = LoginService()
    var userLoggedOut = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.loginService.loginServiceDelegate = self
        
        self.refreshControl?.addTarget(self, action: #selector(MoreTableViewController.refresh), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refresh()
    }
    
    func refresh() {
        RosterManager.sharedInstance.populateRoster()
        self.tableView.reloadData()
        
        if (self.refreshControl?.isRefreshing)! {
            self.refreshControl?.endRefreshing()
        }
    }

    // never empty, no need for no data label
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 4
        
        if RosterManager.sharedInstance.currentUserCanCreateUserChangeAdmin()
            && !RosterManager.sharedInstance.brothersToValidate.isEmpty {
            numRows += 1
        }
        
        return numRows
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell?.textLabel?.text == "Logout" {
            let logoutAlertView = SCLAlertView()
            logoutAlertView.addButton("Logout") {
                self.userLoggedOut = true
                self.loginService.logoutCurrentUser(isCreate: false)
            }
            
            logoutAlertView.showTitle(
                "Logout",
                subTitle: "Are you sure you wish to log out?",
                duration: 0.0,
                completeText: "Cancel",
                style: .warning,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF)
        }
        
        if cell?.textLabel?.text == "Your Info" {
            performSegue(withIdentifier: "yourInfoSegue", sender: self)
        }
        
        if cell?.textLabel?.text == "Change Password" {
            let changePasswordAlert = SCLAlertView()
            let oldPasswordText = changePasswordAlert.addTextField()
            oldPasswordText.isSecureTextEntry = true
            oldPasswordText.placeholder = "Current Password"
            let newPasswordText1 = changePasswordAlert.addTextField()
            newPasswordText1.isSecureTextEntry = true
            newPasswordText1.placeholder = "New Password"
            let newPasswordText2 = changePasswordAlert.addTextField()
            newPasswordText2.isSecureTextEntry = true
            newPasswordText2.placeholder = "New Password Again"
            
            changePasswordAlert.addButton("Submit") {
                if let oldPassword = oldPasswordText.text, let newPassword1 = newPasswordText1.text, let newPassword2 = newPasswordText2.text {
                    if oldPassword.isEmpty {
                        SCLAlertView().showTitle(
                            "Logout",
                            subTitle: "Please enter your current password.",
                            duration: 0.0,
                            completeText: "Okay",
                            style: .warning,
                            colorStyle: Style.mainColorHex,
                            colorTextButton: 0xFFFFFF)
                    } else if newPassword1.isEmpty || newPassword2.isEmpty || newPassword1 != newPassword2 {
                        SCLAlertView().showTitle(
                            "Logout",
                            subTitle: "Please enter your new password twice.",
                            duration: 0.0,
                            completeText: "Okay",
                            style: .warning,
                            colorStyle: Style.mainColorHex,
                            colorTextButton: 0xFFFFFF)
                    } else if newPassword1.characters.count < 6 {
                        SCLAlertView().showTitle(
                            "Logout",
                            subTitle: "Your new password must be at least 6 characters long.",
                            duration: 0.0,
                            completeText: "Okay",
                            style: .warning,
                            colorStyle: Style.mainColorHex,
                            colorTextButton: 0xFFFFFF)
                    } else if oldPassword == newPassword1 {
                        SCLAlertView().showTitle(
                            "Logout",
                            subTitle: "You must choose a new password to change to.",
                            duration: 0.0,
                            completeText: "Okay",
                            style: .warning,
                            colorStyle: Style.mainColorHex,
                            colorTextButton: 0xFFFFFF)
                    } else if newPassword1 == newPassword2 && !oldPassword.isEmpty {
                        self.loginService.changePassword(oldPassword: oldPassword, newPassword: newPassword1)
                    }
                } else {
                    SCLAlertView().showTitle(
                        "Logout",
                        subTitle: "Please enter your current password and your new password.",
                        duration: 0.0,
                        completeText: "Okay",
                        style: .warning,
                        colorStyle: Style.mainColorHex,
                        colorTextButton: 0xFFFFFF)
                }
            }
            
            changePasswordAlert.showTitle(
                "Change Password",
                subTitle: "Enter your new password.",
                duration: 0.0,
                completeText: "Cancel",
                style: .warning,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "yourInfoSegue" {
            let destination = segue.destination as! RosterDetailViewController
            destination.currentBrotherId = RosterManager.sharedInstance.currentUserId
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* DELEGATE METHODS */
    func successfullyLoginLogoutUser(password: String) {
        if self.userLoggedOut {
            self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        } else {
            SCLAlertView().showSuccess("Change Password", subTitle: "Your password was successfully changed!")
        }
    }
    
    func showErrorMessage(message: String) {
        SCLAlertView().showError("Error", subTitle: message)
        self.userLoggedOut = false
    }
}
