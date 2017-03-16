//
//  HirlyNomineeSelectionViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/16/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit

public protocol SelectNomineeDelegate: class {
    func saveSelection(chosenNomineeId: String?)
}

class HirlyNomineeSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var nomineeTableView: UITableView!
    var chosenBrotherId: String!
    var nomineeChoices = Array(RosterManager.sharedInstance.brothersMap.values).filter({
        !$0.hasWonHirly && $0.userId != RosterManager.sharedInstance.currentUserId && ($0.status == Status.Active || $0.status == Status.Associate)
    })
    weak var nomineeDelegate: SelectNomineeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nomineeTableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let chosenBrotherId = self.chosenBrotherId {
            self.nomineeDelegate?.saveSelection(chosenNomineeId: chosenBrotherId)
        } else {
            self.nomineeDelegate?.saveSelection(chosenNomineeId: nil)
        }
    }
    
    // this should NEVER be empty, no need to set empty table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nomineeChoices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nomineeCell", for: indexPath)
        
        cell.textLabel?.text = self.nomineeChoices[indexPath.row].getFullName()

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chosenBrotherId = self.nomineeChoices[indexPath.row].userId
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
