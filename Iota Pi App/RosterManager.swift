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
    var brothersToValidate: [String : User]!
    var currentUserAlreadyLoggedIn = false
    var currentUserAdmin = AdminPrivileges.None
    var currentUserId: String!
    
    private init() {
        self.rosterService.rosterServiceDelegate = self
        self.populateRoster()
    }
    
    public func populateRoster() {
        rosterService.fetchBrothers()
    }
    
    public func sendMap(map: [String : User]) {
        var brothersMap = [String : User]()
        var brothersToValidate = [String : User]()
        
        for (uid, brother) in map {
            if brother.isValidated == true && brother.isDeleted == false {
                brothersMap[uid] = brother
            } else if brother.isDeleted == false {
                brothersToValidate[uid] = brother
            }
        }
        
        self.brothersMap = brothersMap
        self.brothersToValidate = brothersToValidate
        
        Logger().info("‼️ [MANAGER] Log has been populated.")
    }
    
    func currentUserCanCreateAnnouncements() -> Bool {
        return self.currentUserAdmin != AdminPrivileges.None && self.currentUserAdmin != AdminPrivileges.NoVoting
    }
    
    func currentUserCanCreateHirly() -> Bool {
        switch self.currentUserAdmin {
            case .President: return true
            case .BrotherhoodCommitteeChair: return true
            default: return false
        }
    }
    
    func currentUserCanCreateUserChangeAdmin() -> Bool {
        switch self.currentUserAdmin {
            case .President: return true
            case .Webmaster: return true
            default: return false
        }
    }
    
    func currentUserCanCreateVote() -> Bool {
        switch self.currentUserAdmin {
            case .President: return true
            case .RecordingSecretary: return true
            case .VicePresident: return true
            case .Parliamentarian: return true
            default: return false
        }
    }
    
    func currentUserCanDictateMeetings() -> Bool {
        switch self.currentUserAdmin {
            case .President: return true
            case .RecordingSecretary: return true
            case .VicePresident: return true
            default: return false
        }
    }
    
    func currentUserCanEditRoster() -> Bool {
        switch self.currentUserAdmin {
            case .President: return true
            case .RecordingSecretary: return true
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
    
    // unnecessary delegate methods
    public func updateUI(isDeleted: Bool) {}
    public func error(message: String, autoClose: Bool) {}
}
