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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.loginService.loginServiceDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if RosterManager.sharedInstance.currentUserCanCreateUser() && !RosterManager.sharedInstance.brothersToValidate.isEmpty {
            return 4
        }
        
        return 3
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell?.textLabel?.text == "Logout" {
            let logoutAlertView = SCLAlertView()
            logoutAlertView.addButton("Logout") {
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "yourInfoSegue" {
            let destination = segue.destination as! RosterDetailViewController
            destination.currentBrotherId = RosterManager.sharedInstance.currentUserId
        }
    }
    
    func successfullyLoginLogoutUser() {
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    
    func showErrorMessage(message: String) {
        SCLAlertView().showError("Log Out", subTitle: message)
    }
}
