//
//  HirlyNomineeSelectionViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/16/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit

//nomineeCell
class NomineeTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}

class HirlyNomineeSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var nomineeTableView: UITableView!
    var nomineeChoices = Array(RosterManager.sharedInstance.brothersMap.values).filter({!$0.hasWonHirly})
    var currentSelectionIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Hello!! ", RosterManager.sharedInstance)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // print("COUNT:",  String(nomineeChoices.count))
        return nomineeChoices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nomineeCell", for: indexPath) as! NomineeTableViewCell
        
        cell.nameLabel.text = nomineeChoices[indexPath.row].firstname + " " + nomineeChoices[indexPath.row].lastname
        
        cell.accessoryType = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            if let _ = currentSelectionIndexPath {
                cell.accessoryType = .none
                currentSelectionIndexPath = nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("SELECTED:: " + String(indexPath.row))
        if let cell = tableView.cellForRow(at: indexPath){
            if let currentSelectionIndexPath = currentSelectionIndexPath {
                if let oldCell = tableView.cellForRow(at: currentSelectionIndexPath) {
                    oldCell.accessoryType = .none
                }
            }
            
            if currentSelectionIndexPath != indexPath {
                self.currentSelectionIndexPath = indexPath
                cell.accessoryType = .checkmark
            } else {
                self.currentSelectionIndexPath = nil
            }
        }
    }
}
