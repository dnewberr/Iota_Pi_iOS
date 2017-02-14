//
//  RosterManager.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/16/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation
import Firebase
import Log

public class RosterManager: RosterServiceDelegate {
    static let sharedInstance = RosterManager()
    
    let rosterService = RosterService()
    var brothersMap: [String : User]!
    var currentUserId: String!
    var currentUserValidation: Bool?
    
    private init() {
        self.rosterService.rosterServiceDelegate = self
        self.populateRoster()
    }
    
    public func populateRoster() {
        rosterService.fetchBrothers()
    }
    
    public func updateUI() {}
    
    public func sendMap(map: [String : User]) {
        self.brothersMap = map
        if self.currentUserValidation == nil {
            self.currentUserValidation = map[self.currentUserId]?.isValidated
        }
        Logger().info("‼️ [MANAGER] Log has been populated.")
    }
    
    public func sendCurrentBrotherValidation(isValidated: Bool!) {
        self.currentUserValidation = isValidated
    }
    
    func currentUserCanCreateAnnouncements() -> Bool {
        return brothersMap[currentUserId]?.adminPrivileges != AdminPrivileges.None
    }
    
    func currentUserCanCreateHirly() -> Bool {
        let userAdmin = brothersMap[currentUserId]?.adminPrivileges
        
        switch userAdmin {
            case .President?: return true
            case .BrotherhoodCommitteeChair?: return true
            default: return false
        }
    }
    
    func currentUserCanCreateUser() -> Bool {
        let userAdmin = brothersMap[currentUserId]?.adminPrivileges
        
        switch userAdmin {
            case .President?: return true
            case .Webmaster?: return true
            default: return false
        }
    }
    
    func currentUserCanCreateVote() -> Bool {
        let userAdmin = brothersMap[currentUserId]?.adminPrivileges
        
        switch userAdmin {
            case .President?: return true
            case .Parliamentarian?: return true
            default: return false
        }
    }
    
    func currentUserCanDictateMeetings() -> Bool {
        let userAdmin = brothersMap[currentUserId]?.adminPrivileges
        
        switch userAdmin {
            case .President?: return true
            case .RecSec?: return true
            case .VicePresident?: return true
            default: return false
        }
    }
    
    func currentUserCanEditRoster() -> Bool {
        let userAdmin = brothersMap[currentUserId]?.adminPrivileges
        
        switch userAdmin {
            case .President?: return true
            case .RecSec?: return true
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
    

    
//    
//    func markAsPresent() {
//        self.rosterService.checkInBrother()
//    }
}
