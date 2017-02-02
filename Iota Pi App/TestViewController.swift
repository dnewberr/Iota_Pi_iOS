//
//  TestViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/23/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import SCLAlertView

class TestViewController: FormViewController, LoginServiceDelegate {
    let loginService = LoginService()
    
    @IBAction func submitForm(_ sender: AnyObject) {
        let valuesDictionary = form.values()
        var toSubmit = [AnyHashable:Any] ()
        
        for key in valuesDictionary.keys {
            if let value = valuesDictionary[key] {
                if key == "birthday" {
                    toSubmit[key] = Utilities.dateToBirthday(date: (value as! Date))
                } else {
                    toSubmit[key] = value                    
                }
            }
        }
        
        loginService.createNewUser(userInfo: toSubmit)
        
//        FIRDatabase.database().reference().child("Brothers").child("TEST_BRO").setValue(toSubmit)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginService.loginServiceDelegate = self
        
        form = Section("Required")
            <<< TextRow(){ row in
                row.title = "First Name"
                row.placeholder = "John"
                row.tag = "firstname"
                row.add(rule: RuleRequired())
            }
            <<< TextRow(){ row in
                row.title = "Last Name"
                row.placeholder = "Smith"
                row.tag = "lastname"
                row.add(rule: RuleRequired())
            }
            <<< IntRow(){
                $0.title = "Roster Number"
                $0.placeholder = "300"
                $0.tag = "roster"
                $0.add(rule: RuleRequired())
            }
            <<< PickerInlineRow<String>() {
                $0.title = "Admin Privileges"
                $0.options = ["President", "Recording Secretary", "Vice President", "Webmaster", "Parliamentarian", "Brotherhood Committee Chair", "Other Committee Chair", "None"]
                $0.value = "None"    // initially selected
                $0.tag = "admin"
                $0.add(rule: RuleRequired())
            }
            <<< TextRow(){ row in
                row.title = "Class"
                row.placeholder = "Alpha Alpha"
                row.tag = "class"
                row.add(rule: RuleRequired())
            }
            <<< PickerInlineRow<String>() {
                $0.title = "Status"
                $0.options = ["Active", "Alumni", "Conditional", "Inactive", "Other"]
                $0.value = "Active"    // initially selected
                $0.tag = "status"
                $0.add(rule: RuleRequired())
            }
            
            
            +++ Section("Optional")
            <<< TextRow(){ row in
                row.title = "Nickname"
                row.placeholder = "Fancy Pants"
                row.tag = "nickname"
            }
            <<< DateRow(){
                $0.title = "Birthday"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
                $0.tag = "birthday"
            }
            <<< PhoneRow(){
                $0.title = "Phone Number"
                $0.placeholder = "555-555-5555"
                $0.tag = "phone"
            }
            <<< TextRow(){ row in
                row.title = "Expected Graduation"
                row.placeholder = "W2017"
                row.tag = "expectedGrad"
            }
            <<< TextRow(){ row in
                row.title = "Major"
                row.placeholder = "Music"
                row.tag = "major"
            }
            <<< TextRow(){ row in
                row.title = "SLO Address"
                row.placeholder = "1 Grand Ave"
                row.tag = "sloAddress"
            }
            <<< TextRow(){ row in
                row.title = "Section"
                row.placeholder = "Flute"
                row.tag = "section"
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showErrorMessage(message: String) {}
    
    func successfullyLoginLogoutUser() {
        SCLAlertView().showSuccess("Create User", subTitle: "User was successfully created! Their temporary password is \"test123\", and they will be required to change that upon logging in.")
    }
}
