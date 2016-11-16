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
    let firstName: String!
    let educationClass: String!
    let hasWonHirly: Bool!
    let lastName: String!
    let major: String!
    let phoneNumber: String!
    let rosterNumber: Int!
    let section: String!
    let sloAddress: String!
    let status: String!
    let userId: String!
    
    
    init(dict: NSDictionary, userId: String) {
        self.expectedGrad = dict.value(forKey: "expectedGrad") as! String
        self.firstName = dict.value(forKey: "firstName") as! String
        self.educationClass = dict.value(forKey: "educationClass") as! String
        self.hasWonHirly = dict.value(forKey: "hasWonHirly") as! Bool
        self.lastName = dict.value(forKey: "lastName") as! String
        self.major = dict.value(forKey: "major") as! String
        self.phoneNumber = dict.value(forKey: "phoneNumber") as! String
        self.rosterNumber = dict.value(forKey: "rosterNumber") as! Int
        self.section = dict.value(forKey: "section") as! String
        self.sloAddress = dict.value(forKey: "sloAddress") as! String
        self.status = dict.value(forKey: "status") as! String
        self.userId = userId
    }
}
