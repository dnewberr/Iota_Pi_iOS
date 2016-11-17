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
    var archived = false
    
    init(dict: NSDictionary, expiration: Double) {
        self.summary = dict.value(forKey: "summary") as! String
        self.description = dict.value(forKey: "description") as! String
        self.expirationDate = Date(timeIntervalSince1970: expiration)
        
        if (Date() >= self.expirationDate) {
            self.archived = true
        }
    }
}
