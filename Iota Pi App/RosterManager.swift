//
//  RosterManager.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/16/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation
import Firebase

public class RosterManager {
    static let sharedInstance = RosterManager();
    var currentUserId: String!
    var brothersMap = [String : User]()
    
    private init() {
        let ref = FIRDatabase.database().reference().child("Brothers")
        
        ref.observe(.value, with: { (snapshot) -> Void in
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = child.key
                let dict = child.value as! NSDictionary
                let user = User(dict: dict, userId: key)
                self.brothersMap[key] = user
            }
        })
    }
    
    func currentUserCanCreateAnnouncements() -> Bool {
        return brothersMap[currentUserId]?.adminPrivileges != AdminPrivileges.None
    }
    
    func detailToKey(detail: String) -> String? {
        switch detail {
        case "Nickname": return "nickname"
        case "Class": return "class"
        case "Section": return "section"
        case "Birthday": return "birthday"
        case "Slo Address": return "sloAddress"
        case "Major": return "major"
        case "Expected Graduation": return "expectedGrad"
        default: return nil
        }
    }
}
