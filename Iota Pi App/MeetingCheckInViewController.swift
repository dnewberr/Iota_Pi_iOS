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
    @IBOutlet weak var sessionCodeLabel: UILabel!
    @IBOutlet weak var meetingStartEndButton: UIButton!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var meetingLabel: UILabel!
    @IBOutlet weak var sessionCodeTextField: UITextField!
    
    let meetingService = MeetingService()
    var currentMeeting: Meeting!
    
    @IBAction func changeMeetingStatus(_ sender: AnyObject) {
        if meetingStartEndButton.titleLabel?.text == "Start Meeting" {
        } else {
            self.meetingService.pushEndMeeting(meeting: self.currentMeeting)
        }
    }
    
    @IBAction func checkIntoMeeting(_ sender: AnyObject) {
        if let enteredSessionCode = sessionCodeTextField.text {
            if enteredSessionCode != self.currentMeeting.sessionCode {
                SCLAlertView().showError("Meeting Check In", subTitle: "Please enter the valid session meeting code.")
            } else {
                meetingService.checkInBrother(meeting: self.currentMeeting)
            }
        } else {
            SCLAlertView().showError("Meeting Check In", subTitle: "Please enter the valid session meeting code.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sessionCodeTextField.isHidden = true
        self.meetingLabel.isHidden = true
        self.checkInButton.isHidden = true
        self.meetingStartEndButton.isHidden = true
        self.sessionCodeLabel.isHidden = true
        
        self.meetingStartEndButton.isEnabled = false
        
        self.meetingService.meetingServiceDelegate = self
        self.meetingService.fetchCurrentMeeting()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateUI(meeting: Meeting) {
        self.currentMeeting = meeting
        self.sessionCodeTextField.isHidden = false
        self.meetingLabel.isHidden = false
        self.checkInButton.isHidden = false
    }
    
    func noMeeting() {
        SCLAlertView().showInfo("Meeting Check In", subTitle: "There is no active meeting session.").setDismissBlock {
            if !RosterManager.sharedInstance.currentUserCanDictateMeetings() {
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                self.enableStartEndButton(title: "Start Meeting")
            }
        }
    }
    
    func alreadyCheckedIn(meeting: Meeting) {
        SCLAlertView().showInfo("Meeting Check In", subTitle: "You are already checked into the current meeting.").setDismissBlock {
            if !RosterManager.sharedInstance.currentUserCanDictateMeetings() {
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                self.currentMeeting = meeting
                self.enableStartEndButton(title: "End Meeting")
                self.sessionCodeLabel.isHidden = false
                self.sessionCodeLabel.text = "Session Code: " + self.currentMeeting.sessionCode
            }
        }
    }
    
    func enableStartEndButton(title: String) {
        self.meetingStartEndButton.setTitle(title,for: .normal)
        self.meetingStartEndButton.isHidden = false
        self.meetingStartEndButton.isEnabled = true
    }

}
