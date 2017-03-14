//
//  AttendanceTableViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/23/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit
import SCLAlertView

class AttendanceTableViewController: UITableViewController, MeetingServiceDelegate {
    let meetingService = MeetingService()
    var currentMeeting: Meeting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.meetingService.meetingServiceDelegate  = self
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                self.meetingService.fetchCurrentMeeting()
            }
        }
    }
    
    func updateUI(meeting: Meeting) {
        self.currentMeeting = meeting
        self.performSegue(withIdentifier: "checkInSegue", sender: self)
    }
    
    func alreadyCheckedIn(meeting: Meeting) {
            SCLAlertView().showTitle(
                "Meeting Check In",
                subTitle: "You have already checked into the current meeting.",
                duration: 0.0,
                completeText: "Okay",
                style: .info,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF).setDismissBlock {
                if RosterManager.sharedInstance.currentUserCanDictateMeetings() {
                    self.updateUI(meeting: meeting)
                }
            
        }
    }
    
    func noMeeting() {
        SCLAlertView().showTitle(
            "Meeting Check In",
            subTitle: "There is no active meeting.",
            duration: 0.0,
            completeText: "Okay",
            style: .info,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF).setDismissBlock {
            if RosterManager.sharedInstance.currentUserCanDictateMeetings() {
                self.performSegue(withIdentifier: "checkInSegue", sender: self)
            }
        }
    }
    
    func showMessage(message: String, isError: Bool) {
        if isError {
            SCLAlertView().showError("Meeting Check In", subTitle: message)
        } else {
            SCLAlertView().showTitle(
                "Meeting Check In",
                subTitle: message,
                duration: 0.0,
                completeText: "Okay",
                style: .info,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF).setDismissBlock {
                if RosterManager.sharedInstance.currentUserCanDictateMeetings() {
                    self.performSegue(withIdentifier: "checkInSegue", sender: self)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkInSegue" {
            let destination = segue.destination as! MeetingCheckInViewController
            destination.currentMeeting = self.currentMeeting
        }
    }
    
    // unnecessary delegate methods
    func newMeetingCreated(meeting: Meeting) {}
    func populateMeetings(meetings: [Meeting]) {}
}
