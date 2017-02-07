//
//  RosterViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/17/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit

class RosterTableViewCell: UITableViewCell {
    @IBOutlet weak var rosterLabel: UILabel!
    var brotherId: String!
    
}

class RosterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var createUserButton: UIBarButtonItem!
    @IBOutlet weak var rosterTable: UITableView!

    let brothersArray = Array(RosterManager.sharedInstance.brothersMap.values)
    var chosenBrotherId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (RosterManager.sharedInstance.currentUserCanCreateUser()) {
            self.createUserButton.isEnabled = true
            self.createUserButton.tintColor = nil
        } else {
            self.createUserButton.isEnabled = false
            self.createUserButton.tintColor = UIColor.clear
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RosterManager.sharedInstance.brothersMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rosterCell", for: indexPath) as! RosterTableViewCell
        
        let currentBrother = brothersArray[indexPath.row]
        
        cell.brotherId = currentBrother.userId
        cell.rosterLabel.text = currentBrother.firstname + " " + currentBrother.lastname
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let currentCell = tableView.dequeueReusableCell(withIdentifier: "rosterCell", for: indexPath) as! RosterTableViewCell
        if let cell = tableView.cellForRow(at: indexPath) as? RosterTableViewCell {
            chosenBrotherId = cell.brotherId
            performSegue(withIdentifier: "rosterDetailSegue", sender: self)
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rosterDetailSegue" {
            let destination = segue.destination as! RosterDetailViewController
            destination.currentBrotherId = chosenBrotherId
        }
    }
}
