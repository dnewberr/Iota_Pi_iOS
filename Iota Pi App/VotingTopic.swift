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
    var yesCount = 0
    var noCount = 0
    var abstainCount = 0
    var sessionCode = ""
    
    var archived = false
    
    init(dict: NSDictionary, expiration: Double) {
        self.summary = dict.value(forKey: "summary") as! String
        self.description = dict.value(forKey: "description") as! String
        self.id = expiration
        self.expirationDate = Date(timeIntervalSince1970: expiration)
        
        if let sessionCode = dict.value(forKey: "sessionCode") {
            self.sessionCode = sessionCode as! String
        }
        
        if (Date() >= self.expirationDate) {
            self.archived = true
        }
    }
}
