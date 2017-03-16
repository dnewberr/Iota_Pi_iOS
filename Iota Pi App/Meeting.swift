//
//  Meeting.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/10/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import Foundation

public class Meeting: Equatable {
    let sessionCode: String!
    var brotherIdsCheckedIn = [String]()
    var endTime: Date?
    var startTime = Date()
    
    init() {
        self.sessionCode = Utilities.randomString(length: 6)
    }
    
    init(dict: NSDictionary, sessionCode: String) {
        if let startTime = dict.value(forKey: "startTime") as? Double {
            self.startTime = Date(timeIntervalSince1970: startTime)
        }
        
        if let endTime = dict.value(forKey: "endTime") as? Double {
            self.endTime = Date(timeIntervalSince1970: endTime)
        }
        self.sessionCode = sessionCode
        
        if let presentBros = dict.value(forKey: "brotherIdsCheckedIn") as? [String] {
            for uid in presentBros {
                if RosterManager.sharedInstance.brothersMap[uid] != nil {
                    self.brotherIdsCheckedIn.append(uid)
                }
            }
        }
    }
    
    func isCurrentBroCheckedIn() -> Bool {
        return RosterManager.sharedInstance.brothersMap[RosterManager.sharedInstance.currentUserId]!.lastMeetingId == self.sessionCode
    }
    
    func toFirebaseObject() -> [AnyHashable:Any] {
        return [
            "startTime": floor(self.startTime.timeIntervalSince1970),
            "brotherIdsCheckedIn": self.brotherIdsCheckedIn
        ]
    }
}

public func ==(lhs:Meeting, rhs:Meeting) -> Bool {
    return lhs.sessionCode == rhs.sessionCode
}
