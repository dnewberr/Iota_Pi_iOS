//
//  ArchivedMeetingDetailViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/22/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit

class ArchivedMeetingDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var currentMeeting: Meeting?
    var brosPresent = [User]()
    
    @IBOutlet weak var brosPresentTable: UITableView!
    @IBOutlet weak var numBrosPresentLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        for uid in (self.currentMeeting?.brotherIdsCheckedIn)! {
            self.brosPresent.append(RosterManager.sharedInstance.brothersMap[uid]!)
        }
        self.brosPresent.sort {
            $0.lastname < $1.lastname
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.brosPresent.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "brotherPresentCell", for: indexPath)
        
        cell.textLabel?.text = self.brosPresent[indexPath.row].firstname + " " + self.brosPresent[indexPath.row].lastname
        
        return cell
    }

}
