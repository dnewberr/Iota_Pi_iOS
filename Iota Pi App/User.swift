//
//  User.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/16/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation

public class User {
    let expectedGrad: String!
    let firstname: String!
    let educationClass: String!
    let hasWonHirly: Bool!
    let lastname: String!
    let major: String!
    let nickname: String?
    let phoneNumber: String!
    let rosterNumber: Int!
    let section: String!
    let sloAddress: String!
    let status: Status!
    let userId: String!
    
    
    init(dict: NSDictionary, userId: String) {
        self.expectedGrad = dict.value(forKey: "expectedGrad") as! String
        self.firstname = dict.value(forKey: "firstname") as! String
        self.educationClass = dict.value(forKey: "class") as! String
        self.hasWonHirly = dict.value(forKey: "hasWonHirly") as! Bool
        self.lastname = dict.value(forKey: "lastname") as! String
        self.major = dict.value(forKey: "major") as! String
        self.nickname = dict.value(forKey: "nickname") as? String
        self.phoneNumber = dict.value(forKey: "phone") as! String
        self.rosterNumber = dict.value(forKey: "roster") as! Int
        self.section = dict.value(forKey: "section") as! String
        self.sloAddress = dict.value(forKey: "sloAddress") as! String
        
        switch dict.value(forKey: "status") as! String {
            case "Active" : self.status = Status.Active
            case "Alumni" : self.status = Status.Alumni
            case "Conditional" : self.status = Status.Conditional
            case "Inactive" : self.status = Status.Inactive
            default : self.status = Status.Other
        }
        
        self.userId = userId
    }
}
