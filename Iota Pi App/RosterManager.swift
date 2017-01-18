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
    
    let baseRef = FIRDatabase.database().reference().child("Brothers")
    var currentUserId: String!
    var brothersMap = [String : User]()
    
    private init() {
        baseRef.observe(.value, with: { (snapshot) -> Void in
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
    
    func currentUserCanCreateHirly() -> Bool {
        let userAdmin = (brothersMap[currentUserId]?.adminPrivileges)!
        
        switch userAdmin {
            case .President: return true
            case .BrotherhoodCommitteeChair: return true
            default: return false
        }
    }
    
    func currentUserCanCreateUser() -> Bool {
        let userAdmin = (brothersMap[currentUserId]?.adminPrivileges)!
        
        switch userAdmin {
            case .President: return true
            case .Webmaster: return true
            default: return false
        }
    }
    
    func currentUserCanCreateVote() -> Bool {
        let userAdmin = (brothersMap[currentUserId]?.adminPrivileges)!
        
        switch userAdmin {
            case .President: return true
            case .Parliamentarian: return true
            default: return false
        }
    }
    
    func currentUserCanDictateMeetings() -> Bool {
        let userAdmin = (brothersMap[currentUserId]?.adminPrivileges)!
        
        switch userAdmin {
            case .President: return true
            case .RecSec: return true
            case .VicePresident: return true
            default: return false
        }
    }
    
    func currentUserCanEditRoster() -> Bool {
        let userAdmin = (brothersMap[currentUserId]?.adminPrivileges)!
        
        switch userAdmin {
            case .President: return true
            case .RecSec: return true
            default: return false
        }
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
    
    func markAsPresent() {
        baseRef.child(self.currentUserId).child("isCheckedIn").setValue(true)
    }
    
    
    
}
