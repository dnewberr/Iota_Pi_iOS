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
    let id: Double!
    var broHasVoted = false
    var sessionCode = ""
    var archived = false
    
    init(dict: NSDictionary, expiration: Double) {
        self.summary = dict.value(forKey: "summary") as! String
        self.description = dict.value(forKey: "description") as! String
        self.id = expiration
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
}
