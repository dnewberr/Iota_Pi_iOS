//
//  HirlyNomineeSelectionViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/16/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit

public protocol SelectNomineeDelegate: class {
    func saveSelection(chosenNominee: User?)
}

//nomineeCell
class NomineeTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    var user: User!
}

class HirlyNomineeSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var nomineeTableView: UITableView!
    var nomineeChoices = Array(RosterManager.sharedInstance.brothersMap.values).filter({!$0.hasWonHirly})
    var chosenCell: NomineeTableViewCell!
    weak var nomineeDelegate: SelectNomineeDelegate?
    
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
        cell.user = nomineeChoices[indexPath.row]
        cell.accessoryType = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            if let _ = chosenCell {
                cell.accessoryType = .none
                chosenCell = nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            if let chosenCell = chosenCell {
                chosenCell.accessoryType = .none
            }
            
            if chosenCell != cell {
                self.chosenCell = cell as! NomineeTableViewCell
                cell.accessoryType = .checkmark
            } else {
                self.chosenCell = nil
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        if let chosenCell = chosenCell {
            self.nomineeDelegate?.saveSelection(chosenNominee: chosenCell.user)
        } else {
            self.nomineeDelegate?.saveSelection(chosenNominee: nil)
        }
    }
}
