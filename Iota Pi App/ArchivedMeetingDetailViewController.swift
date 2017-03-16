//
//  ArchivedMeetingDetailViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/22/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit

class ArchivedMeetingDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var brosPresent = [User]()
    var currentMeeting: Meeting?
    
    @IBOutlet weak var brosPresentTable: UITableView!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var numBrosPresentLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.brosPresentTable.tableFooterView = UIView()
        
        self.title = Utilities.dateToDay(date: (self.currentMeeting?.startTime)!)
        self.startTimeLabel.text = Utilities.dateToTime(date: (self.currentMeeting?.startTime)!)
        self.endTimeLabel.text = Utilities.dateToTime(date: (self.currentMeeting?.endTime)!)
        
        self.getBroNames()
        
        self.numBrosPresentLabel.text = String(describing: self.brosPresent.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getBroNames() {
        for uid in self.currentMeeting!.brotherIdsCheckedIn {
            self.brosPresent.append(RosterManager.sharedInstance.brothersMap[uid]!)
        }
        
        self.brosPresent.sort {
            $0.lastname < $1.lastname
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if !self.brosPresent.isEmpty {
            tableView.backgroundView = nil
            return 1
        } else {
            tableView.backgroundView = Utilities.createNoDataLabel(message: "No brothers present.", width: tableView.bounds.size.width, height: tableView.bounds.size.height)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.brosPresent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "brotherPresentCell", for: indexPath)
        
        cell.textLabel?.text = self.brosPresent[indexPath.row].getFullName()
        
        return cell
    }
}
