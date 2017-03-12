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
                $0.options = ["President", "RecordingSecretary", "VicePresident", "Webmaster", "Parliamentarian", "BrotherhoodCommitteeChair", "OtherCommitteeChair", "None"]
                $0.value = RosterManager.sharedInstance.brothersMap[self.currentBrotherId]!.adminPrivileges!.rawValue // initially selected
                $0.tag = "admin"
                $0.hidden = Condition.function(["admin"], { form in //only show to those that can edit admin privileges
                    return !RosterManager.sharedInstance.currentUserCanCreateUserChangeAdmin()
                })
                $0.add(rule: RuleRequired())
            }
            <<< PickerInlineRow<String>() {
                $0.title = "Status"
                $0.options = ["Active", "Alumni", "Conditional", "Inactive", "Other"]
                $0.value = RosterManager.sharedInstance.brothersMap[self.currentBrotherId]!.status!.rawValue // initially selected
                $0.tag = "status"
                $0.add(rule: RuleRequired())
            }
    }
    
    func requiredFieldsFilled(userInfoKeys: [AnyHashable]) -> Bool {
        return userInfoKeys.contains("firstname")
            && userInfoKeys.contains("lastname")
            && userInfoKeys.contains("roster")
            && userInfoKeys.contains("class")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func updateUI() {
        if !self.alreadyUpdated {
            self.alreadyUpdated = true
            SCLAlertView().showSuccess("Change Admin and Status", subTitle: "The user's admin and status have been saved.").setDismissBlock {
                self.performSegue(withIdentifier: "unwindToDetail", sender: self)
            }
        }
    }
    
    func error(message: String) {
        SCLAlertView().showError("Error", subTitle: message)
    }
    
    // unnecessary delegate method
    func sendMap(map: [String : User]) {}
}
