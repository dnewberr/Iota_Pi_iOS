//
//  User.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/16/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation

public class User: Equatable {
    // noneditable data
    var email = "" //generated
    var firstname = "" //required
    var lastname = "" //required
    var hasWonHirly = false // is the user able to be nominated for hirly
    var isDeleted = false// is user marked to be deleted
    var isValidated = false // is user able to log in
    var rosterNumber = -1//required
    var userId = "" //required
    
    // editable data
    var adminPrivileges = AdminPrivileges.None //required
    var educationClass = ""//required
    var expectedGrad = "N/A"
    var birthday = "N/A"
    var lastHirlyId = ""
    var lastMeetingId = ""
    var lastVoteId = ""
    var major = "N/A"
    var nickname = "N/A"
    var phoneNumber = "N/A"
    var section = "N/A"
    var sloAddress = "N/A"
    var status = Status.Active //required
    
    
    init(dict: NSDictionary, userId: String) {
        /* REQUIRED */
        if let firstname = dict.value(forKey: "firstname") as? String {
            self.firstname = firstname
        }
        
        if let lastname = dict.value(forKey: "lastname") as? String {
            self.lastname = lastname
        }
        
        if let rosterNumber = dict.value(forKey: "roster") as? Int { // created via firebase
            self.rosterNumber = rosterNumber
        } else if let rosterNumber = dict.value(forKey: "roster") as? NSString { // created in-app
            self.rosterNumber = rosterNumber.integerValue
        }
        
        if let admin = dict.value(forKey: "admin") as? String {
            switch admin {
                case "President" : self.adminPrivileges = AdminPrivileges.President
                case "Vice President" : self.adminPrivileges = AdminPrivileges.VicePresident
                case "Recording Secretary" : self.adminPrivileges = AdminPrivileges.RecordingSecretary
                case "Parliamentarian" : self.adminPrivileges = AdminPrivileges.Parliamentarian
                case "Brotherhood Committee Chair" : self.adminPrivileges = AdminPrivileges.BrotherhoodCommitteeChair
                case "Other Committee Chair" : self.adminPrivileges  = AdminPrivileges.OtherCommitteeChair
                case "Webmaster" : self.adminPrivileges = AdminPrivileges.Webmaster
                default : self.adminPrivileges = AdminPrivileges.None
            }
        }
        
        if let educationClass = dict.value(forKey: "class") as? String {
            self.educationClass = educationClass
        }
        
        // any status other than active or associate automatically can't vote, so admin is revoked
        if let status = dict.value(forKey: "status") as? String {
            switch status {
                case "Active" : self.status = Status.Active
                case "Associate" : self.status = Status.Associate
                case "Alumni" : self.status = Status.Alumni
                    self.adminPrivileges = AdminPrivileges.NoVoting
                case "Conditional" : self.status = Status.Conditional
                    self.adminPrivileges = AdminPrivileges.NoVoting
                case "Honorary" : self.status = Status.Honorary
                    self.adminPrivileges = AdminPrivileges.NoVoting
                case "Life" : self.status = Status.Life
                    self.adminPrivileges = AdminPrivileges.NoVoting
                default : self.status = Status.Inactive
                    self.adminPrivileges = AdminPrivileges.NoVoting
            }
        }
        
        /* OPTIONAL */
        if let birthday = dict.value(forKey: "birthday") as? String {
            self.birthday = birthday
        }
        
        if let expectedGrad = dict.value(forKey: "expectedGrad") as? String {
            self.expectedGrad = expectedGrad
        }
        
        if let hasWonHirly = dict.value(forKey: "hasWonHirly") as? Bool {
            self.hasWonHirly = hasWonHirly
        }
        
        if let lastHirlyId = dict.value(forKey: "lastHirlyId") as? String {
            self.lastHirlyId = lastHirlyId
        }
        
        if let lastMeetingId = dict.value(forKey: "lastMeetingId") as? String {
            self.lastMeetingId = lastMeetingId
        }
        
        if let lastVoteId = dict.value(forKey: "lastVoteId") as? String {
            self.lastVoteId = lastVoteId
        }
        
        if let isDeleted = dict.value(forKey: "isDeleted") as? Bool {
            self.isDeleted = isDeleted
        }
        
        if let isValidated = dict.value(forKey: "isValidated") as? Bool {
            self.isValidated = isValidated
        }
        
        if let major = dict.value(forKey: "major") as? String {
            self.major = major
        }
        
        if let nickname = dict.value(forKey: "nickname") as? String {
            self.nickname = nickname
        }
        
        if let phone = dict.value(forKey: "phone") as? String {
            self.phoneNumber = phone
        }
        
        if let section = dict.value(forKey: "section") as? String {
            self.section = section
        }
        
        if let sloAddress = dict.value(forKey: "sloAddress") as? String {
            self.sloAddress = sloAddress
        }
        
        /* GENERATED */
        self.email = self.firstname.trim().lowercased() + "." + self.lastname.trim().lowercased() + "@iotapi.com"
        self.userId = userId
    }
    
    func getArrayOfDetails() -> [String] {
        return [
            "Nickname",
            "Class",
            "Section",
            "Birthday",
            "Slo Address",
            "Major",
            "Expected Graduation",
            "Phone Number"
        ]
    }
    
    func getFullName() -> String {
        return self.firstname + " " + self.lastname
    }
    
    func toArrayOfEditableInfo() -> [String] {
        return [
            self.nickname,
            self.educationClass,
            self.section,
            self.birthday,
            self.sloAddress,
            self.major,
            self.expectedGrad,
            self.phoneNumber
        ]
    }
}

public func ==(lhs:User, rhs:User) -> Bool {
    return lhs.userId == rhs.userId
}
