//
//  MeetingCheckInViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/10/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit
import SCLAlertView

class MeetingCheckInViewController: UIViewController, MeetingServiceDelegate {
    @IBOutlet weak var sessionCodeTextField: UITextField!
    
    let meetingService = MeetingService()
    var currentMeeting: Meeting!
    
    @IBAction func checkIntoMeeting(_ sender: AnyObject) {
        if let enteredSessionCode = sessionCodeTextField.text {
            if enteredSessionCode != self.currentMeeting.sessionCode {
                SCLAlertView().showError("Meeting Check In", subTitle: "Please enter the valid session meeting code.")
            } else {
                //check in
            }
        } else {
            SCLAlertView().showError("Meeting Check In", subTitle: "Please enter the valid session meeting code.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.meetingService.meetingServiceDelegate = self
        self.meetingService.fetchCurrentMeeting()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateUI(meeting: Meeting) {
        self.currentMeeting = meeting
    }
    
    func noMeeting() {
        SCLAlertView().showInfo("Meeting Check In", subTitle: "There is no active meeting session.").setDismissBlock {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func alreadyCheckedIn() {
        SCLAlertView().showInfo("Meeting Check In", subTitle: "You are already checked into the current meeting.").setDismissBlock {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }

}
