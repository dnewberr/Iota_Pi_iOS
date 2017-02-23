//
//  PreviousMeetingsViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/22/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit
import SCLAlertView

class PreviousMeetingsTableViewCell: UITableViewCell {
    @IBOutlet weak var meetingDateLabel: UILabel!
    @IBOutlet weak var meetingCodeLabel: UILabel!
    var meeting: Meeting!
}

class ArchivedMeetingsTableViewController: UITableViewController, MeetingServiceDelegate {
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBAction func searchForMeeting(_ sender: AnyObject) {
        let alertView = SCLAlertView()
        let sessionCodeText = alertView.addTextField()
        sessionCodeText.placeholder = "Session Code"
        sessionCodeText.text = self.activeKeyphrase
        sessionCodeText.autocorrectionType = .no
        sessionCodeText.autocapitalizationType = .none
        
        alertView.showTitle(
            "Archived Meetings",
            subTitle: "Search for a meeting by its session code.",
            duration: 0.0,
            completeText: "Search",
            style: .notice,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF).setDismissBlock {
            if let sessionCode = sessionCodeText.text {
                self.activeKeyphrase = sessionCode
                self.filterMeetings()
            }
            
        }
    }
    
    @IBAction func clearFilter(_ sender: Any) {
        self.activeKeyphrase = ""
        self.filterMeetings()
    }
    
    func filterMeetings() {
        self.filteredMeetings.removeAll()
        
        if !self.activeKeyphrase.isEmpty {
            self.clearButton.isEnabled = true
            self.clearButton.tintColor = nil
            
            for meeting in self.archivedMeetings {
                if meeting.sessionCode.lowercased().contains(self.activeKeyphrase.trim().lowercased()) {
                    self.filteredMeetings.append(meeting)
                }
            }
        } else {
            self.filteredMeetings = self.archivedMeetings
            self.clearButton.isEnabled = false
            self.clearButton.tintColor = UIColor.clear
        }
        
        self.tableView.reloadData()
    }

    var archivedMeetings = [Meeting]()
    var filteredMeetings = [Meeting]()
    var meetingService = MeetingService()
    var meetingToPass: Meeting?
    var activeKeyphrase = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearButton.isEnabled = false
        self.clearButton.tintColor = UIColor.clear
        self.tableView.tableFooterView = UIView()
        
        self.refreshControl?.addTarget(self, action: #selector(ArchivedMeetingsTableViewController.refresh), for: UIControlEvents.valueChanged)
        
        self.meetingService.meetingServiceDelegate = self
        self.meetingService.fetchAllArchivedMeetings()
    }
    
    func refresh() {
        self.meetingService.fetchAllArchivedMeetings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !self.filteredMeetings.isEmpty {
            tableView.backgroundView = nil
            return 1
        } else {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No data available"
            noDataLabel.textColor = Style.tintColor
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredMeetings.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "previousMeetingsCell", for: indexPath) as!    PreviousMeetingsTableViewCell
        
        cell.meeting = self.filteredMeetings[indexPath.row]
        cell.meetingCodeLabel.text = cell.meeting.sessionCode
        cell.meetingDateLabel.text = Utilities.dateToDayTime(date: cell.meeting.startTime) //TODO
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! PreviousMeetingsTableViewCell
        meetingToPass = currentCell.meeting
        performSegue(withIdentifier: "meetingDetailsSegue", sender: self)
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "meetingDetailsSegue" {
            let destination = segue.destination as! ArchivedMeetingDetailViewController
            destination.currentMeeting = self.meetingToPass
        }
    }
    
    func populateMeetings(meetings: [Meeting]) {
        self.archivedMeetings = meetings.sorted {
            $0.endTime! > $1.endTime!
        }

        self.filterMeetings()
        if (self.refreshControl?.isRefreshing)! {
            self.refreshControl?.endRefreshing()
        }
    }
    
    // unnecessary delegate methods
    func updateUI(meeting: Meeting) {}
    func alreadyCheckedIn(meeting: Meeting) {}
    func noMeeting() {}
    func newMeetingCreated(meeting: Meeting) {}
}
