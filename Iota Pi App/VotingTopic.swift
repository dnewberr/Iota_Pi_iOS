//
//  VotingTopic.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/14/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation


public class VotingTopic {
    let summary: String!
    let description: String!
    let expirationDate: Date!
    var broHasVoted = false
    var sessionCode = ""
    var archived = false
    
    init(summary: String, description: String, isSessionCodeRequired: Bool) {
        self.summary = summary
        self.description = description
        if isSessionCodeRequired {
            var fifteenMinInterval = DateComponents()
            fifteenMinInterval.minute = 15
            self.expirationDate = Calendar.current.date(byAdding: fifteenMinInterval, to: Date())!
            self.sessionCode = Utilities.randomString(length: 6)
        } else {
            self.expirationDate = Utilities.getWeekExpirationDate()
        }
    }
    
    init(dict: NSDictionary, expiration: Double) {
        self.summary = dict.value(forKey: "summary") as! String
        self.description = dict.value(forKey: "description") as! String
        self.expirationDate = Date(timeIntervalSince1970: expiration)
        
        if let brosWhoVoted = dict.value(forKey: "brosVoted") as? [String : Bool] {
            if let broHasVoted = brosWhoVoted[RosterManager.sharedInstance.currentUserId] {
                self.broHasVoted = broHasVoted
            }
        }
        
        if let sessionCode = dict.value(forKey: "sessionCode") {
            self.sessionCode = sessionCode as! String
        }
        
        if (Date() >= self.expirationDate) {
            self.archived = true
        }
    }
    
    func toFirebaseObject() -> [AnyHashable:Any] {
        return !sessionCode.isEmpty
            ? [
                "summary": self.summary,
                "description": self.description,
                "sessionCode": self.sessionCode
            ]
            : [
                "summary": self.summary,
                "description": self.description
        ]
    }
    
    func getId() -> String {
        return String(format: "%.0f", self.expirationDate.timeIntervalSince1970)
    }
}
