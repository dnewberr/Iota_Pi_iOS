//
//  Announcement.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/2/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation


public class Announcement: Equatable {
    let details: String
    let expirationDate: Date
    let title: String
    var archived = false
    
    init(title: String, details: String) {
        self.title = title
        self.details = details
        self.expirationDate = Utilities.getWeekExpirationDate()
    }
    
    init(dict: NSDictionary, expiration: Double) {
        self.title = dict.value(forKey: "title") as! String
        self.details = dict.value(forKey: "details") as! String
        self.expirationDate = Date(timeIntervalSince1970: expiration)
        
        if (Date() >= self.expirationDate) {
            self.archived = true
        }
    }
    
    func toFirebaseObject() -> Any {
        return [
            "title": self.title,
            "details": self.details
        ]
    }
    
    func getId() -> String {
        return String(format: "%.0f", self.expirationDate.timeIntervalSince1970)
    }
}

public func ==(lhs:Announcement, rhs:Announcement) -> Bool {
    return lhs.expirationDate == rhs.expirationDate && lhs.title == rhs.title
        && lhs.details == rhs.details
}
