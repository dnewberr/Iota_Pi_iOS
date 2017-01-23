//
//  Utilities.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/16/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation
import UIKit

enum Status: String {
    case Active, Alumni, Conditional, Inactive, Other
}

enum AdminPrivileges: String {
    case President, RecSec, VicePresident, Webmaster, Parliamentarian, BrotherhoodCommitteeChair, OtherCommitteeChair, None
}


class Utilities {
    static let DATA_EXPIRATION = 2629743 * 4
    
    static func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    static func getWeekExpirationDate() -> Date {
        var oneWeekInterval = DateComponents()
        oneWeekInterval.day = 7
        return Calendar.current.date(byAdding: oneWeekInterval, to: Date())!
    }
    
    static func createActivityIndicator(center: CGPoint) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.hidesWhenStopped = true
        indicator.center = center
        
        return indicator
    }
    
    static func dateToDay(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
    
    static func dateToTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        return dateFormatter.string(from: date)
    }
    
    static func dateToDayTime(date: Date) -> String {
        return dateToDay(date: date) + ", " + dateToTime(date: date)
    }
    
}
