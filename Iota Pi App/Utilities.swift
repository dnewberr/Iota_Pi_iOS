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
    case Active, Associate, Alumni, Conditional, Honorary, Inactive, Life
    static let ALL_VALUES = ["Active", "Associate", "Alumni", "Conditional", "Honorary", "Inactive", "Life"]
}

// NoVoting is internal only based on status (anything but active or alumni)
enum AdminPrivileges: String {
    case BrotherhoodCommitteeChair, None, NoVoting, OtherCommitteeChair, Parliamentarian, President, RecordingSecretary, VicePresident, Webmaster
    static let ALL_VALUES = ["Brotherhood Committee Chair", "None", "Other Committee Chair", "Parliamentarian", "President", "Recording Secretary", "Vice President", "Webmaster"]
}

// Main and tint colors for the app
struct Style {
    static var mainColor = UIColor(red: 0.02, green: 0.10, blue: 0.25, alpha: 1.0) //dark kkpsi blue
    static var mainColorHex: UInt = 0x061A40
    static var tintColor = UIColor(red: 0.45, green: 0.58, blue: 0.82, alpha: 1.0) //lighter blue
    static var tintColorHex: UInt = 0x7395D0
}

//Removes all whitespace from a string
extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Changes background of UI button depending on states
extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
}

class Utilities {
    static let ANIMATION_DURATION = 0.25
    static let SECONDS_IN_WEEK: Double = 604800
    static let SECONDS_IN_YEAR: Double = 31557600
    
    // creates a generic activity indicator
    static func createActivityIndicator(center: CGPoint) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.hidesWhenStopped = true
        indicator.center = center
        
        return indicator
    }
    
    // creates a no data label useful for tables
    static func createNoDataLabel(message: String, width: CGFloat, height: CGFloat) -> UILabel {
        let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        noDataLabel.text = message
        noDataLabel.textColor = Style.tintColor
        noDataLabel.textAlignment = .center
        return noDataLabel
    }
    
    // returns a random string of numbers and letters, case sensitive
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
    
    /* DATE HELPERS */
    
    // Month/Day/Year
    static func dateToDay(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
    
    // Month/Day/Year, Hour:Minute AM/PM
    static func dateToDayTime(date: Date) -> String {
        return dateToDay(date: date) + ", " + dateToTime(date: date)
    }
    
    // Hour:Minute AM/PM
    static func dateToTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        return dateFormatter.string(from: date)
    }
    
    // returns a date exactly 7 days from now
    static func getWeekExpirationDate() -> Date {
        var oneWeekInterval = DateComponents()
        oneWeekInterval.day = 7
        return Calendar.current.date(byAdding: oneWeekInterval, to: Date())!
    }
    
    // Checks to see if a date is atleast one year old (+ a 7 day buffer for manually archived items)
    static func isOlderThanOneYear(date: Date) -> Bool {
        return !(Date(timeIntervalSinceNow: -SECONDS_IN_YEAR)...Date(timeIntervalSinceNow: SECONDS_IN_WEEK)).contains(date)
    }
}
