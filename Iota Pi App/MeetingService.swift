//
//  MeetingService.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/10/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import Foundation
import Firebase

public protocol MeetingServiceDelegate: class {
    func updateUI(meeting: Meeting)
    func alreadyCheckedIn(meeting: Meeting)
    func noMeeting()
}

public class MeetingService {
    weak var meetingServiceDelegate: MeetingServiceDelegate?
    let baseRef = FIRDatabase.database().reference().child("Meetings")
    
    init() {}
    
    func fetchCurrentMeeting() {
        baseRef.observe(.value, with:{ (snapshot) -> Void in
            var meeting: Meeting?
            
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let dict = child.value as! NSDictionary
                let currentMeeting = Meeting(dict: dict, sessionCode: child.key)
                
                if currentMeeting.endTime == nil {
                    meeting = currentMeeting
                }
            }
            
            if let meeting = meeting {
                if meeting.isCurrentBroCheckedIn() {
                    self.meetingServiceDelegate?.alreadyCheckedIn(meeting: meeting)
                } else {
                    self.meetingServiceDelegate?.updateUI(meeting: meeting)
                }
            } else {
                self.meetingServiceDelegate?.noMeeting()
            }
        })
    }
    
    func checkInBrother(meeting: Meeting) {
        var brosPresent = meeting.brotherIdsCheckedIn
        brosPresent.append(RosterManager.sharedInstance.currentUserId)
        baseRef.child(meeting.sessionCode).child("brotherIdsCheckedIn").setValue(brosPresent)
        RosterManager.sharedInstance.markAsPresent()
    }
    
    func pushEndMeeting(meeting: Meeting) {
        baseRef.child(meeting.sessionCode).child("endTime").setValue(floor(Date().timeIntervalSince1970))
    }
    
    func startNewMeeting() {
        
    }
}
