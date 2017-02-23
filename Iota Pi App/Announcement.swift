//
//  Announcement.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/2/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation


public class Announcement: Equatable {
    let committeeTags: [String]
    let details: String
    let expirationDate: Date
    let title: String
    var archived = false
    
    init(title: String, details: String, committeeTags: [String]) {
        self.committeeTags = committeeTags
        self.title = title
        self.details = details
        self.expirationDate = Utilities.getWeekExpirationDate()
    }
    
    init(dict: NSDictionary, expiration: Double) {
        if let committeeTags = dict.value(forKey: "committeeTags") as? [String] {
            self.committeeTags = committeeTags.sorted {
                $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
            }

        } else {
            self.committeeTags = [String]()
        }
        self.title = dict.value(forKey: "title") as! String
        self.details = dict.value(forKey: "details") as! String
        self.expirationDate = Date(timeIntervalSince1970: expiration)
        
        if (Date() >= self.expirationDate) {
            self.archived = true
        }
    }
    
    func toFirebaseObject() -> [AnyHashable:Any] {
        return [
            "title": self.title,
            "details": self.details,
            "committeeTags": self.committeeTags
        ]
    }
    
    func getId() -> String {
        return String(format: "%.0f", self.expirationDate.timeIntervalSince1970)
    }
    
    func getCommitteeTagList() -> String {
        var list = ""
        
        if self.committeeTags.isEmpty {
            return list
        }
        
        for tag in self.committeeTags {
            list += tag + ", "
        }
        
        return String(list.characters.dropLast(2))
    }
}

public func ==(lhs:Announcement, rhs:Announcement) -> Bool {
    return lhs.expirationDate == rhs.expirationDate && lhs.title == rhs.title
        && lhs.details == rhs.details
}
