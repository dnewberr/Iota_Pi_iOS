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
    func showMessage(message: String, isError: Bool)
}

public class MeetingService {
    public static let LOGGER = Logger(formatter: Formatter("📘 [%@] %@ %@: %@", .date("dd/MM/yy HH:mm"), .location, .level, .message), theme: nil, minLevel: .trace)
    
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
                    if Utilities.isOlderThanOneYear(date: currentMeeting.endTime!) {
                        self.deleteMeeting(sessionCode: currentMeeting.sessionCode, meetings: [])
                    } else {
                        meetings.append(currentMeeting)
                    }
                }
            }
            
            MeetingService.LOGGER.info("[Fetch Archived Meetings] Found " + String(meetings.count) + " archived meetings.")
            self.meetingServiceDelegate?.populateMeetings(meetings: meetings)
            
        })
    }
    
    func checkInBrother(meeting: Meeting) {
        MeetingService.LOGGER.info("[Check In Brother] Marking current user present for meeting with session code " + meeting.sessionCode)
        
        baseRef.child(meeting.sessionCode).runTransactionBlock({(currentData: FIRMutableData!) in
            var value =  currentData.childData(byAppendingPath: "brotherIdsCheckedIn").value as? NSMutableArray
            
            if value == nil {
                value = NSMutableArray()
            }
            
            value!.add(RosterManager.sharedInstance.currentUserId)
            currentData.childData(byAppendingPath: "brotherIdsCheckedIn").value = value!.copy() as! NSArray

            return FIRTransactionResult.success(withValue: currentData)
        }, andCompletionBlock: {error, commited, snap in
            if commited {
                MeetingService.LOGGER.info("[Check In Brother] Checked in currentuser for meeting with session code " + meeting.sessionCode)
            } else {
                MeetingService.LOGGER.error("[Check In Brother] Could not check in current user for meeting with session code " + meeting.sessionCode)
                self.meetingServiceDelegate?.showMessage(message: "There was an issue in recording your attendance.", isError: true)
            }
        })
    }
    
    func pushEndMeeting(meeting: Meeting) {
        MeetingService.LOGGER.info("[End Meeting] Setting end time for meeting with session code " + meeting.sessionCode)
        
        baseRef.child(meeting.sessionCode).child("endTime").setValue(floor(Date().timeIntervalSince1970), withCompletionBlock: { (error, ref) in
            if let error = error {
                MeetingService.LOGGER.error("[End Meeting] " + error.localizedDescription)
                self.meetingServiceDelegate?.showMessage(message: "An error occurred while trying to end the meeting.", isError: true)
            } else {
                //no need to call delegate method - observer automatically will update the UI
                MeetingService.LOGGER.info("[End Meeting] Meeting ended for session code " + meeting.sessionCode)
            }
        })
        
    }
    
    func startNewMeeting() {
        let newMeeting = Meeting()
        MeetingService.LOGGER.info("[Start New Meeting] Creating a new meeting with session code " + newMeeting.sessionCode)
        
        baseRef.child(newMeeting.sessionCode).setValue(newMeeting.toFirebaseObject(), withCompletionBlock: { (error, ref) in
            if let error = error {
                MeetingService.LOGGER.error("[Start Meeting] " + error.localizedDescription)
                self.meetingServiceDelegate?.showMessage(message: "An error occurred while trying to create the meeting.", isError: true)
            } else {
                MeetingService.LOGGER.info("[Start New Meeting] Meeting created with session code " + newMeeting.sessionCode)
                self.meetingServiceDelegate?.newMeetingCreated(meeting: newMeeting)
            }
        })
    }
    
    func deleteMeeting(sessionCode: String, meetings: [Meeting]) {
        MeetingService.LOGGER.info("[Delete Meeting] Deleting meeting with ID \(sessionCode)")

        baseRef.child(sessionCode).removeValue(completionBlock: { (error, ref) in
            if let error = error {
                VotingService.LOGGER.error("[Delete Vote] " + error.localizedDescription)
                self.meetingServiceDelegate?.showMessage(message: "An error occurred while trying to delete the meeting.", isError: true)
            } else {
                MeetingService.LOGGER.info("[Delete Meeting] Meeting with ID \(sessionCode) was successfully deleted.")
                if !meetings.isEmpty {
                    self.meetingServiceDelegate?.populateMeetings(meetings: meetings.filter({$0.sessionCode != sessionCode}))
                }
            }
        })
    }
}
