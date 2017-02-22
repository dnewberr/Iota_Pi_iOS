//
//  User.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/16/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation
import Log

public class User: Equatable {
    // noneditable data
    let adminPrivileges: AdminPrivileges! //required
    let email: String! //generated
    let firstname: String! //required
    let hasWonHirly: Bool! // is the user able to be nominated for hirly
//    let isCheckedIn: Bool!
    let isDeleted: Bool! // is user marked to be deleted
    let isValidated: Bool! // is user able to log in
    let lastname: String! //required
    let rosterNumber: Int! //required
    let status: Status! //required
    let userId: String! //required
    
    // editable data
    var educationClass: String! //required
    var expectedGrad: String!
    var birthday: String!
    var major: String!
    var nickname: String!
    var phoneNumber: String!
    var section: String!
    var sloAddress: String!
    
    init(dict: NSDictionary, userId: String) {
        // required
        self.firstname = dict.value(forKey: "firstname") as! String
        self.lastname = dict.value(forKey: "lastname") as! String
        
        if let rosterNumber = dict.value(forKey: "roster") as? Int { // created via firebase
            self.rosterNumber = rosterNumber
        } else if let rosterNumber = dict.value(forKey: "roster") as? NSString { // created in-app
            self.rosterNumber = rosterNumber.integerValue
        } else { // requirement to assign lets in init; invalid roster #
            self.rosterNumber = -1
        }
        
        switch dict.value(forKey: "admin") as! String {
            case "President" : self.adminPrivileges = AdminPrivileges.President
            case "VicePresident" : self.adminPrivileges = AdminPrivileges.VicePresident
            case "RecSec" : self.adminPrivileges = AdminPrivileges.RecSec
            case "Parliamentarian" : self.adminPrivileges = AdminPrivileges.Parliamentarian
            case "BrotherhoodCommitteeChair" : self.adminPrivileges = AdminPrivileges.BrotherhoodCommitteeChair
            case "OtherCommitteeChair" : self.adminPrivileges  = AdminPrivileges.OtherCommitteeChair
            case "Webmaster" : self.adminPrivileges = AdminPrivileges.Webmaster
            default : self.adminPrivileges = AdminPrivileges.None
        }
        
        self.educationClass = dict.value(forKey: "class") as! String
        
        switch dict.value(forKey: "status") as! String {
            case "Active" : self.status = Status.Active
            case "Alumni" : self.status = Status.Alumni
            case "Conditional" : self.status = Status.Conditional
            case "Inactive" : self.status = Status.Inactive
            default : self.status = Status.Other
        }
        
        // optional
        if let birthday = dict.value(forKey: "birthday") as? String {
            self.birthday = birthday
        } else {
            self.birthday = "N/A"
        }
        
        if let expectedGrad = dict.value(forKey: "expectedGrad") as? String {
            self.expectedGrad = expectedGrad
        } else {
            self.expectedGrad = "N/A"
        }
        
        // TODO
        if let hasWonHirly = dict.value(forKey: "hasWonHirly") as? Bool {
            self.hasWonHirly = hasWonHirly
        } else {
            self.hasWonHirly = false
        }
        
        
//        // TODO?
//        if let isCheckedIn = dict.value(forKey: "isCheckedIn") as? Bool {
//            self.isCheckedIn = isCheckedIn
//        } else {
//            self.isCheckedIn = false
//        }
        
        
        if let isDeleted = dict.value(forKey: "isDeleted") as? Bool {
            self.isDeleted = isDeleted
        } else {
            self.isDeleted = false
        }
        
        if let isValidated = dict.value(forKey: "isValidated") as? Bool {
            self.isValidated = isValidated
        } else {
            self.isValidated = false
        }
        Logger().info("USER : isValidated\(self.isValidated)")
        
        if let major = dict.value(forKey: "major") as? String {
            self.major = major
        } else {
            self.major = "N/A"
        }
        
        if let nickname = dict.value(forKey: "nickname") as? String {
            self.nickname = nickname
        } else {
            self.nickname = "N/A"
        }
        
        if let phone = dict.value(forKey: "phone") as? String {
            self.phoneNumber = phone
        } else {
            self.phoneNumber = "N/A"
        }
        
        if let section = dict.value(forKey: "section") as? String {
            self.section = section
        } else {
            self.section = "N/A"
        }
        
        if let sloAddress = dict.value(forKey: "sloAddress") as? String {
            self.sloAddress = sloAddress
        } else {
            self.sloAddress = "N/A"
        }
        
        // generated
        self.email = self.firstname.lowercased() + "." + self.lastname.lowercased() + "@iotapi.com"
        self.userId = userId
    }
    
    func toFirebaseObject() -> Any {
        return [
            "birthday": self.birthday,
            "expectedGrad": self.expectedGrad,
            "firstname": self.firstname,
            "lastname": self.lastname,
            "class": self.educationClass,
            "hasWonHirly": self.hasWonHirly,
            "major": self.major,
            "nickname": self.nickname,
            "phone": self.phoneNumber,
            "roster": self.rosterNumber,
            "section": self.section,
            "sloAddress": self.sloAddress,
            "status": self.status.rawValue,
            "admin": self.adminPrivileges.rawValue
        ]
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
}

public func ==(lhs:User, rhs:User) -> Bool {
    return lhs.userId == rhs.userId
}
