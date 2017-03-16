//
//  Announcement.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/2/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation


public class Announcement: Equatable {
    var committeeTags = [String]()
    var details = "N/A"
    var expirationDate = Utilities.getWeekExpirationDate()
    var isArchived = false
    var title = "N/A"
    
    init(title: String, details: String, committeeTags: [String]) {
        self.committeeTags = committeeTags
        self.title = title
        self.details = details
        self.expirationDate = Utilities.getWeekExpirationDate()
    }
    
    init(dict: NSDictionary, expiration: Double) {
        self.expirationDate = Date(timeIntervalSince1970: expiration)
        
        if let committeeTags = dict.value(forKey: "committeeTags") as? [String] {
            self.committeeTags = committeeTags.sorted {
                $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
            }
        }
        
        if let title = dict.value(forKey: "title") as? String {
            self.title = title
        }
        
        if let details = dict.value(forKey: "details") as? String {
            self.details = details
        }
        
        if let isArchived = dict.value(forKey: "isArchived") as? Bool {
            self.isArchived = isArchived
        } else {
            self.isArchived = Date() >= self.expirationDate
        }
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
    
    func getId() -> String {
        return String(format: "%.0f", self.expirationDate.timeIntervalSince1970)
    }
    
    func toFirebaseObject() -> [AnyHashable:Any] {
        return [
            "title": self.title,
            "details": self.details,
            "committeeTags": self.committeeTags
        ]
    }
}

public func ==(lhs:Announcement, rhs:Announcement) -> Bool {
    return lhs.expirationDate == rhs.expirationDate && lhs.title == rhs.title
        && lhs.details == rhs.details
}
