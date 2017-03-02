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
            self.meetingService.pushEndMeeting(meeting: self.currentMeeting)
            self.sessionCodeLabel.isHidden = true
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
        self.meetingService.meetingServiceDelegate = self
        
        self.resetView()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MeetingCheckInViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.meetingService.fetchCurrentMeeting()
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
    
    func updateUI(meeting: Meeting) {
        self.currentMeeting = meeting
        
        self.meetingLabel.isHidden = false
        self.checkInButton.isHidden = false
        
        self.sessionCodeTextField.isHidden = false
        
        if RosterManager.sharedInstance.currentUserCanDictateMeetings() {
            self.sessionCodeLabel.isHidden = false
            self.sessionCodeLabel.text = "Session Code: " + self.currentMeeting.sessionCode
        }
        
    }
    
    func noMeeting() {
        if let _ = self.currentMeeting {
            SCLAlertView().showSuccess("Meeting Check In", subTitle: "The meeting was successfully closed.").setDismissBlock {
//                if !RosterManager.sharedInstance.currentUserCanDictateMeetings() {
//                    _ = self.navigationController?.popViewController(animated: true)
//                } else {
                    self.enableStartEndButton(title: "Start Meeting")
//                }
            }
        } else {
            SCLAlertView().showTitle(
                "Meeting Check In",
                subTitle: "There is no active meeting session.",
                duration: 0.0,
                completeText: "Okay",
                style: .notice,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF).setDismissBlock {
                if !RosterManager.sharedInstance.currentUserCanDictateMeetings() {
                    _ = self.navigationController?.popViewController(animated: true)
                } else {
                    self.enableStartEndButton(title: "Start Meeting")
                }
            }
        }
        
    }
    
    func alreadyCheckedIn(meeting: Meeting) {
        if self.currentMeeting != nil && meeting == self.currentMeeting {
            SCLAlertView().showSuccess("Meeting Check In", subTitle: "You've successfully checked into the meeting!").setDismissBlock {
                self.createCheckInDismissBlock(meeting: meeting)
            }
        } else {
            SCLAlertView().showTitle(
                "Meeting Check In",
                subTitle: "You have checked into the current meeting.",
                duration: 0.0,
                completeText: "Okay",
                style: .info,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF).setDismissBlock {
                self.createCheckInDismissBlock(meeting: meeting)
            }
        }
    }
    
    func newMeetingCreated(meeting: Meeting) {
        self.resetView()
        SCLAlertView().showSuccess("Meeting Check In", subTitle: "A new meeting has started with session code: " + meeting.sessionCode)
        
        self.currentMeeting = meeting
        self.sessionCodeTextField.text = ""
        self.sessionCodeLabel.text = "Session Code: " + self.currentMeeting.sessionCode
    }
    
    func resetView() {
        self.sessionCodeTextField.isHidden = true
        self.meetingLabel.isHidden = true
        self.checkInButton.isHidden = true
        self.meetingStartEndButton.isHidden = true
        self.sessionCodeLabel.isHidden = true
        self.meetingStartEndButton.isEnabled = false
    }
    
    func createCheckInDismissBlock(meeting: Meeting) {
        if !RosterManager.sharedInstance.currentUserCanDictateMeetings() {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            self.currentMeeting = meeting
            
            self.enableStartEndButton(title: "End Meeting")
            
            self.sessionCodeLabel.isHidden = false
            self.sessionCodeLabel.text = "Session Code: " + self.currentMeeting.sessionCode
            
            self.sessionCodeTextField.isHidden = true
            self.meetingLabel.isHidden = true
            self.checkInButton.isHidden = true
        }

    }
    
    func enableStartEndButton(title: String) {
        self.meetingStartEndButton.setTitle(title,for: .normal)
        self.meetingStartEndButton.isHidden = false
        self.meetingStartEndButton.isEnabled = true
    }
    
    //unnecessary delegate funcs
    func populateMeetings(meetings: [Meeting]) {}
    func showMessage(message: String) {}
}
