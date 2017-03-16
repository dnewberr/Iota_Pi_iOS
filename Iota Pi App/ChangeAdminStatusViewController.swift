//
//  ChangeAdminStatusViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 2/23/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit
import Eureka
import SCLAlertView

class ChangeAdminStatusViewController: FormViewController, RosterServiceDelegate {
    let rosterService = RosterService()
    var alreadyUpdated = false // necessary bc service method calls update ui twice, only want one alert to show
    var currentBrotherId: String!
    
    @IBAction func submitChanges(_ sender: Any) {
        for (key, value) in form.values() {
            self.rosterService.pushBrotherDetail(brotherId: self.currentBrotherId, key: key, value: value as! String)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rosterService.rosterServiceDelegate = self
        
        form +++ Section()
            <<< PickerInlineRow<String>() {
                $0.title = "Admin Privileges"
                $0.options = AdminPrivileges.ALL_VALUES
                $0.value = RosterManager.sharedInstance.brothersMap[self.currentBrotherId]!.adminPrivileges.rawValue // initially selected
                $0.tag = "admin"
                $0.hidden = Condition.function(["admin"], { form in //only show to those that can edit admin privileges
                    return !RosterManager.sharedInstance.currentUserCanCreateUserChangeAdmin()
                })
                $0.add(rule: RuleRequired())
            }
            <<< PickerInlineRow<String>() {
                $0.title = "Status"
                $0.options = Status.ALL_VALUES
                $0.value = RosterManager.sharedInstance.brothersMap[self.currentBrotherId]!.status.rawValue // initially selected
                $0.tag = "status"
                $0.add(rule: RuleRequired())
            }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* DELEGATE METHODS */
    func updateUI(isDeleted: Bool) {
        if !self.alreadyUpdated {
            self.alreadyUpdated = true
            SCLAlertView().showSuccess("Change Admin and Status", subTitle: "The user's admin and status have been saved.").setDismissBlock {
                self.performSegue(withIdentifier: "unwindToDetail", sender: self)
            }
        }
    }
    
    func error(message: String, autoClose: Bool) {
        SCLAlertView().showError("Error", subTitle: message)
    }
    
    // unnecessary delegate method
    func sendMap(map: [String : User]) {}
}
