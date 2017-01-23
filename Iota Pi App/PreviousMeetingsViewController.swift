//
//  PreviousMeetingsViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/22/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit

class PreviousMeetingsTableViewCell: UITableViewCell {
    @IBOutlet weak var meetingDateLabel: UILabel!
    @IBOutlet weak var meetingCodeLabel: UILabel!
    var meeting: Meeting!
}

class PreviousMeetingsTableViewController: UITableViewController, MeetingServiceDelegate {
    var archivedMeetings = [Meeting]()
    var meetingService = MeetingService()
    var meetingToPass: Meeting?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        meetingService.meetingServiceDelegate = self
        meetingService.fetchAllArchivedMeetings()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archivedMeetings.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "previousMeetingsCell", for: indexPath) as!    PreviousMeetingsTableViewCell
        
        cell.meeting = archivedMeetings[indexPath.row]
        cell.meetingCodeLabel.text = cell.meeting.sessionCode
        cell.meetingDateLabel.text = cell.meeting.startTime.description //TODO
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! PreviousMeetingsTableViewCell
        meetingToPass = currentCell.meeting
        print(meetingToPass?.sessionCode)
        //performSegue(withIdentifier: "announcementDetailsSegue", sender: self)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func populateMeetings(meetings: [Meeting]) {
        self.archivedMeetings = meetings
        
        self.tableView.reloadData()
        print("POPULATE MEETINGS")
    }
    
    // unnecessary delegate methods
    func updateUI(meeting: Meeting) {}
    func alreadyCheckedIn(meeting: Meeting) {}
    func noMeeting() {}
    func newMeetingCreated(meeting: Meeting) {}

}
