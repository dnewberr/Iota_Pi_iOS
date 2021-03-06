//
//  PreviousMeetingsViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/22/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit
import SCLAlertView

class ArchivedMeetingsTableViewController: UITableViewController, MeetingServiceDelegate {
    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    var activeKeyphrase = ""
    var archivedMeetings = [Meeting]()
    var filteredMeetings = [Meeting]()
    var meetingService = MeetingService()
    var meetingToPass: Meeting?
    
    @IBAction func searchForMeeting(_ sender: AnyObject) {
        let searchAlert = SCLAlertView()
        let sessionCodeText = searchAlert.addTextField()
        sessionCodeText.placeholder = "Session Code"
        sessionCodeText.text = self.activeKeyphrase
        sessionCodeText.autocorrectionType = .no
        sessionCodeText.autocapitalizationType = .none
        
        searchAlert.addButton("Search") {
            if let sessionCode = sessionCodeText.text {
                self.activeKeyphrase = sessionCode
                self.filterMeetings()
            }
        }
        
        searchAlert.showTitle(
            "Archived Meetings",
            subTitle: "Search for a meeting by its session code or present members.",
            duration: 0.0,
            completeText: "Cancel",
            style: .notice,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF)
    }
    
    @IBAction func clearFilter(_ sender: Any) {
        self.activeKeyphrase = ""
        self.filterMeetings()
    }
    
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
    
    func filterMeetings() {
        self.filteredMeetings.removeAll()
        
        if !self.activeKeyphrase.isEmpty {
            self.clearButton.isEnabled = true
            self.clearButton.tintColor = nil
            
            for meeting in self.archivedMeetings {
                let usersCheckedIn = meeting.brotherIdsCheckedIn.map({RosterManager.sharedInstance.brothersMap[$0]!})
                
                // filters by sessions code and present member's first/last/nickname
                let trimmedFilter = self.activeKeyphrase.trim().lowercased()
                if meeting.sessionCode.lowercased().contains(trimmedFilter)
                    || !usersCheckedIn.filter({
                        $0.firstname.lowercased().contains(trimmedFilter)
                            || $0.lastname.lowercased().contains(trimmedFilter)
                            || $0.nickname.lowercased().contains(trimmedFilter)}).isEmpty {
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !self.filteredMeetings.isEmpty {
            tableView.backgroundView = nil
            return 1
        } else {
            tableView.backgroundView = Utilities.createNoDataLabel(message: "No meetings found.", width: tableView.bounds.size.width, height: tableView.bounds.size.height)
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredMeetings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "previousMeetingsCell", for: indexPath)
        
        let meeting = self.filteredMeetings[indexPath.row]
        cell.textLabel?.text = meeting.sessionCode
        cell.detailTextLabel?.text = Utilities.dateToDayTime(date: meeting.startTime)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let deleteMeetingAlert = SCLAlertView()
            deleteMeetingAlert.addButton("Delete") {
                self.meetingService.deleteMeeting(sessionCode: self.filteredMeetings[indexPath.row].sessionCode, meetings: self.archivedMeetings)
            }
            
            deleteMeetingAlert.showTitle(
                "Delete Meeting",
                subTitle: "Are you sure you want to delete this meeting?",
                duration: 0.0,
                completeText: "Cancel",
                style: .warning,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.meetingToPass = self.filteredMeetings[indexPath.row]
        performSegue(withIdentifier: "meetingDetailsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "meetingDetailsSegue" {
            let destination = segue.destination as! ArchivedMeetingDetailViewController
            destination.currentMeeting = self.meetingToPass
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* DELEGATE METHODS */
    func populateMeetings(meetings: [Meeting]) {
        self.archivedMeetings = meetings.sorted {
            $0.endTime! > $1.endTime!
        }

        self.filterMeetings()
        if (self.refreshControl?.isRefreshing)! {
            self.refreshControl?.endRefreshing()
        }
    }
    
    func showMessage(message: String, isError: Bool) {
        if isError {
            SCLAlertView().showError("Error", subTitle: message)
        } else {
            SCLAlertView().showTitle(
                "Delete Meeting",
                subTitle: message,
                duration: 0.0,
                completeText: "Okay",
                style: .notice,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF)
        }
    }
    
    // unnecessary delegate methods
    func updateUI(meeting: Meeting) {}
    func alreadyCheckedIn(meeting: Meeting) {}
    func noMeeting() {}
    func newMeetingCreated(meeting: Meeting) {}
    func checkInSuccess(meeting: Meeting) {}
}
