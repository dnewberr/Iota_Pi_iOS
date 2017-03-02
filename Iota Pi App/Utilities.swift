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

struct Style {
    static var mainColor = UIColor(red:0.02, green:0.10, blue:0.25, alpha:1.0) //dark kkpsi blue
    static var mainColorHex: UInt = 0x061A40
    static var tintColor = UIColor(red:0.45, green:0.58, blue:0.82, alpha:1.0) //lighter blue
    static var tintColorHex: UInt = 0x7395D0
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


class Utilities {
    static let SECONDS_IN_WEEK: Double = 604800
    static let SECONDS_IN_YEAR: Double = 31557600
    
    static func isOlderThanOneYear(date: Date) -> Bool {
        return !(Date(timeIntervalSinceNow: -SECONDS_IN_YEAR)...Date(timeIntervalSinceNow: SECONDS_IN_WEEK)).contains(date) // 7 day buffer for manually archived
    }
    
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
    
    static func dateToBirthday(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
    
}
