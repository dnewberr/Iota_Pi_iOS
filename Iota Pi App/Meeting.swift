//
//  Meeting.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/10/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import Foundation

public class Meeting {
    let sessionCode: String!
    let startTime: Date!
    var endTime: Date?
    var brotherIdsCheckedIn = [String]()
    
    init() {
        self.startTime = Date()
        self.sessionCode = Utilities.randomString(length: 6)
    }
    
    init(dict: NSDictionary, sessionCode: String) {
        print("HERE")
        self.startTime = Date(timeIntervalSince1970: (dict.value(forKey: "startTime") as! Double))
        if let endTime = dict.value(forKey: "endTime") as? Double {
            self.endTime = Date(timeIntervalSince1970: endTime)
        }
        self.sessionCode = sessionCode
        
        if let presentBros = dict.value(forKey: "brotherIdsCheckedIn") as? [String] {
            self.brotherIdsCheckedIn = presentBros
        }
    }

    
    func isCurrentBroCheckedIn() -> Bool {
        return brotherIdsCheckedIn.contains(RosterManager.sharedInstance.currentUserId)
    }
}
