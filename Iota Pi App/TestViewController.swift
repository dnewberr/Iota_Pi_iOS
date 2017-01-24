//
//  TestViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/23/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit
import Eureka

class TestViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
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
            <<< PhoneRow(){
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
        
        let valuesDictionary = form.values()
        
        print(valuesDictionary)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
