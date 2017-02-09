//
//  MeetingService.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/10/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import Foundation
import Firebase
import Log

public protocol MeetingServiceDelegate: class {
    func updateUI(meeting: Meeting)
    func alreadyCheckedIn(meeting: Meeting)
    func noMeeting()
    func newMeetingCreated(meeting: Meeting)
    func populateMeetings(meetings: [Meeting])
}

public class MeetingService {
    public static let LOGGER = Logger(formatter: Formatter("📘 [%@] %@ %@: %@", .date("dd/MM/yy HH:mm"), .location, .level, .message),
                                      theme: nil, minLevel: .trace)
    
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
                    MeetingService.LOGGER.info("[Fetch Current Meeting] Found current meeting with session code: " + currentMeeting.sessionCode)
                    meeting = currentMeeting
                }
            }
            
            if let meeting = meeting {
                if meeting.isCurrentBroCheckedIn() {
                    MeetingService.LOGGER.trace("[Fetch Current Meeting] Current user has already checked in.")
                    self.meetingServiceDelegate?.alreadyCheckedIn(meeting: meeting)
                } else {
                    self.meetingServiceDelegate?.updateUI(meeting: meeting)
                }
            } else {
                MeetingService.LOGGER.trace("[Fetch Current Meeting] No active meeting found.")
                self.meetingServiceDelegate?.noMeeting()
            }
        })
    }
    
    func fetchAllArchivedMeetings() {
        baseRef.observe(.value, with:{ (snapshot) -> Void in
            var meetings = [Meeting]()
            
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let dict = child.value as! NSDictionary
                let currentMeeting = Meeting(dict: dict, sessionCode: child.key)
                
                if currentMeeting.endTime != nil {
                    meetings.append(currentMeeting)
                }
            }
            
            MeetingService.LOGGER.info("[Fetch Archived Meetings] Found " + String(meetings.count) + " archived meetings.")
            self.meetingServiceDelegate?.populateMeetings(meetings: meetings)
            
        })
    }
    
    func checkInBrother(meeting: Meeting) {
        MeetingService.LOGGER.info("[Check In Brother] Marking current user present for meeting with session code " + meeting.sessionCode)
        var brosPresent = meeting.brotherIdsCheckedIn
        brosPresent.append(RosterManager.sharedInstance.currentUserId)
        baseRef.child(meeting.sessionCode).child("brotherIdsCheckedIn").setValue(brosPresent)
        //RosterManager.sharedInstance.markAsPresent()
    }
    
    func pushEndMeeting(meeting: Meeting) {
        MeetingService.LOGGER.info("[Push End Meeting] Setting end time for meeting with session code " + meeting.sessionCode)
        baseRef.child(meeting.sessionCode).child("endTime").setValue(floor(Date().timeIntervalSince1970))
    }
    
    func startNewMeeting() {
        let newMeeting = Meeting()
        MeetingService.LOGGER.info("[Start New Meeting] Creating a new meeting with session code " + newMeeting.sessionCode)
        baseRef.child(newMeeting.sessionCode).setValue(newMeeting.toFirebaseObject())
        self.meetingServiceDelegate?.newMeetingCreated(meeting: newMeeting)
    }
}
