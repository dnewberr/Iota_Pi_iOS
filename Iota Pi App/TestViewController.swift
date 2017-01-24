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
            }
            <<< TextRow(){ row in
                row.title = "Last Name"
                row.placeholder = "Smith"
            }
            <<< PhoneRow(){
                $0.title = "Roster Number"
                $0.placeholder = "300"
            }
            <<< ActionSheetRow<String>() {
                $0.title = "Admin Privileges"
                $0.selectorTitle = "Pick an admin priviledge"
                $0.options = ["President", "Recording Secretary", "Vice President", "Webmaster", "Parliamentarian", "Brotherhood Committee Chair", "Other Committee Chair", "None"]
                $0.value = "None"    // initially selected
            }
            <<< TextRow(){ row in
                row.title = "Class"
                row.placeholder = "Alpha Alpha"
            }
            <<< ActionSheetRow<String>() {
                $0.title = "Status"
                $0.selectorTitle = "Pick a status"
                $0.options = ["Active", "Alumni", "Conditional", "Inactive", "Other"]
                $0.value = "Active"    // initially selected
            }
            
            
            +++ Section("Optional")
            <<< TextRow(){ row in
                row.title = "Nickname"
                row.placeholder = "Fancy Pants"
            }
            <<< DateRow(){
                $0.title = "Birthday"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            <<< PhoneRow(){
                $0.title = "Phone Number"
                $0.placeholder = "555-555-5555"
            }
            <<< TextRow(){ row in
                row.title = "Expected Graduation"
                row.placeholder = "W2017"
            }
            <<< TextRow(){ row in
                row.title = "Major"
                row.placeholder = "Music"
            }
            <<< TextRow(){ row in
                    row.title = "SLO Address"
                    row.placeholder = "1 Grand Ave"
            }
            <<< TextRow(){ row in
                    row.title = "Section"
                    row.placeholder = "Flute"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
