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
    func alreadyCheckedIn()
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
                    self.meetingServiceDelegate?.alreadyCheckedIn()
                } else {
                    self.meetingServiceDelegate?.updateUI(meeting: meeting)
                }
            } else {
                self.meetingServiceDelegate?.noMeeting()
            }
        })
    }
}
