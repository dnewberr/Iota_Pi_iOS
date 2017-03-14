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
    
    var isArchived = false
//    var broHasVoted = false
    
    // currentvote only
    var abstainVotes = 0
    var noVotes = 0
    var sessionCode = ""
    var yesVotes = 0
    
    // hirly only
    var winners = [String : [String]]()
    
    init(summary: String, description: String, isHirly: Bool) {
        self.summary = summary
        self.description = description
        if !isHirly {
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
                
        if let sessionCode = dict.value(forKey: "sessionCode") as? String {
            self.sessionCode = sessionCode
        }
        
        if let isArchived = dict.value(forKey: "isArchived") as? Bool {
            self.isArchived = isArchived
        } else {
            self.isArchived = Date() >= self.expirationDate
        }
        
        // Current vote only
        if let numAbstain = dict.value(forKey: "abstainCount") as? Int {
            self.abstainVotes = numAbstain
        }
        if let numNo = dict.value(forKey: "noCount") as? Int {
            self.noVotes = numNo
        }
        if let numYes = dict.value(forKey: "yesCount") as? Int {
            self.yesVotes = numYes
        }
        
        if let winners = dict.value(forKey: "winners") as? [String : [String]] {
            self.winners = winners
        }
        
    }
    
    func getWinnerNames() -> String {
        if !self.hasWinners() {
            return "N/A"
        }
        
        var numWinner = 0
        var names = ""
        
        for (id, _) in winners {
            if let user = RosterManager.sharedInstance.brothersMap[id] {
                names += (user.firstname)! + " " + (user.lastname)!
            }
            
            if numWinner < winners.count - 1 {
                names += "; "
            }
            
            numWinner += 1
        }
        
        return names
    }
    
    func hasWinners() -> Bool {
        return !self.winners.isEmpty
    }

    func hasCurrentBroVoted(isHirly: Bool) -> Bool {
        let currentUser = RosterManager.sharedInstance.brothersMap[RosterManager.sharedInstance.currentUserId]!
        return isHirly ? currentUser.lastHirlyId! == self.getId() : currentUser.lastVoteId == self.getId()
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


