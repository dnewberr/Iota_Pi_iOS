//
//  MeetingCheckInViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/10/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit
import SCLAlertView

class MeetingCheckInViewController: UIViewController, MeetingServiceDelegate, UITextFieldDelegate {
    @IBOutlet weak var sessionCodeLabel: UILabel!
    @IBOutlet weak var meetingStartEndButton: UIButton!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var meetingLabel: UILabel!
    @IBOutlet weak var sessionCodeTextField: UITextField!
    
    let meetingService = MeetingService()
    var currentMeeting: Meeting!
    
    @IBAction func changeMeetingStatus(_ sender: AnyObject) {
        if meetingStartEndButton.titleLabel?.text == "Start Meeting" {
            self.meetingService.startNewMeeting()
        } else {
            self.sessionCodeLabel.isHidden = true
            self.meetingService.pushEndMeeting(meeting: self.currentMeeting)
        }
    }
    
    @IBAction func checkIntoMeeting(_ sender: AnyObject) {
        if let enteredSessionCode = sessionCodeTextField.text {
            if enteredSessionCode != self.currentMeeting.sessionCode {
                SCLAlertView().showError("Meeting Check In", subTitle: "Please enter the valid session meeting code.")
            } else {
                self.meetingService.checkInBrother(meeting: self.currentMeeting)
            }
        } else {
            SCLAlertView().showError("Meeting Check In", subTitle: "Please enter the valid session meeting code.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.meetingService.meetingServiceDelegate = self
        
        self.resetView()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MeetingCheckInViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    // Closes keyboard when tapped outside textfields
    func dismissKeyboard() {
        view.endEditing(true)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if self.sessionCodeTextField == textField {
            textField.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func updateUI(meeting: Meeting) {}
    
    func noMeeting() {
        SCLAlertView().showSuccess("Meeting Check In", subTitle: "The meeting was successfully closed.").setDismissBlock {
            self.currentMeeting = nil
            self.resetView()
        }
    }
    
    func alreadyCheckedIn(meeting: Meeting) {
        SCLAlertView().showSuccess("Meeting Check In", subTitle: "You've successfully checked into the meeting!").setDismissBlock {
            self.createCheckInDismissBlock(meeting: meeting)
        }
    }
    
    func newMeetingCreated(meeting: Meeting) {
        SCLAlertView().showSuccess("Meeting Check In", subTitle: "A new meeting has started with session code: " + meeting.sessionCode).setDismissBlock {
            self.currentMeeting = meeting
            self.resetView()
        }
    }
    
    func resetView() {
        // There is a currently active meeting
        if self.currentMeeting != nil {
            // The brother on this page is already checked in, which means they must be admin
            if self.currentMeeting.isCurrentBroCheckedIn() {
                self.meetingLabel.isHidden = true
                self.checkInButton.isHidden = true
                self.sessionCodeLabel.isHidden = false
                self.sessionCodeLabel.text = "Session Code: " + self.currentMeeting.sessionCode
                self.enableStartEndButton(title: "End Meeting")
                self.sessionCodeTextField.isHidden = true
            } else {
                // The brother on this page needs to check in and could be either admin or none
                self.meetingLabel.isHidden = false
                self.checkInButton.isHidden = false
                self.sessionCodeTextField.isHidden = false
                
                if RosterManager.sharedInstance.currentUserCanDictateMeetings() {
                    self.sessionCodeLabel.isHidden = false
                    self.sessionCodeLabel.text = "Session Code: " + self.currentMeeting.sessionCode
                    self.enableStartEndButton(title: "End Meeting")
                } else {
                    self.meetingStartEndButton.isHidden = true
                    self.sessionCodeLabel.isHidden = true
                }
            }
        } else {
            // Because there is no meeting, this brother must be admin and must only be able to create a meeting
            self.meetingLabel.isHidden = true
            self.checkInButton.isHidden = true
            self.sessionCodeTextField.isHidden = true
            self.sessionCodeLabel.isHidden = true
            self.enableStartEndButton(title: "Start Meeting")
        }
    }
    
    func createCheckInDismissBlock(meeting: Meeting) {
        if !RosterManager.sharedInstance.currentUserCanDictateMeetings() {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            self.currentMeeting = meeting
            self.resetView()
        }
    }
    
    func enableStartEndButton(title: String) {
        self.meetingStartEndButton.setTitle(title, for: .normal)
        self.meetingStartEndButton.isHidden = false
        self.meetingStartEndButton.isEnabled = true
    }
    
    //unnecessary delegate funcs
    func populateMeetings(meetings: [Meeting]) {}
    
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
                    self.createCheckInDismissBlock(meeting: self.currentMeeting)
            }
        }
    }
}
