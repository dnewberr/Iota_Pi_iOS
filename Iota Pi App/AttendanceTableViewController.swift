//
//  AttendanceTableViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/23/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit
import SCLAlertView

class AttendanceTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if RosterManager.sharedInstance.currentUserCanDictateMeetings() {
            return 3
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell?.textLabel?.text == "Check Into Meeting" {
            if RosterManager.sharedInstance.currentUserAdmin == .NoVoting {
                SCLAlertView().showError("Check Into Meeting", subTitle: "You are not a fully active member and thus cannot check into the current meeting.")
            } else {
                self.performSegue(withIdentifier: "checkInSegue", sender: self)
            }
        }
    }
}
