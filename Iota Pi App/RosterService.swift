//
//  RosterService.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 12/8/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation
import Firebase
import Log

public protocol RosterServiceDelegate: class {
    func updateUI(isDeleted: Bool)
    func sendMap(map: [String : User])
    func error(message: String, autoClose: Bool)
}

public class RosterService {
    public static let LOGGER = Logger(formatter: Formatter("📘 [%@] %@ %@: %@", .date("dd/MM/yy HH:mm"), .location, .level, .message),
                                      theme: nil, minLevel: .trace)
    weak var rosterServiceDelegate: RosterServiceDelegate?
    let baseRef = FIRDatabase.database().reference().child("Brothers")
    
    init() {}
    
    func fetchBrothers() {
        var brothersMap = [String : User]()
        
        self.baseRef.observe(.value, with: { (snapshot) -> Void in
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = child.key
                let dict = child.value as! NSDictionary
                let user = User(dict: dict, userId: key)
                brothersMap[key] = user
                
                RosterService.LOGGER.info("[Fetch Brothers] Retrieved info for brother with UID: " + key)
            }
            
            self.rosterServiceDelegate?.sendMap(map: brothersMap)
        })
    }
    
    func pushBrotherDetail(brotherId: String, key: String, value: String) {
        RosterService.LOGGER.info("[Push Brother Detail] Pushing [\(key) : \(value)] for brother with UID: " + brotherId)
        
        // Edit database for permanent changes; local edited already
        baseRef.child(brotherId).child(key).setValue(value, withCompletionBlock: {(error, ref) in
            if let error = error {
                RosterService.LOGGER.info("[Push Brother Detail] \(error.localizedDescription)")
                self.rosterServiceDelegate?.error(message: "An error has occured that prevents your changes from being saved.", autoClose: false)
            } else {
                self.rosterServiceDelegate?.updateUI(isDeleted: false)
            }
        })
    }
    
    func validateBrothers(uids: [String]) {
        var errorCount = 0
        
        // Can only validate bros in loop with an internet connection
        FIRDatabase.database().reference(withPath: ".info/connected").observeSingleEvent(of: .value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                // using a for loop to properly update UI if there are errors
                for i in 0...uids.count - 1 {
                    let uid = uids[i]
                    RosterService.LOGGER.info("[Validate Brothers] Validating brother with UID: " + uid)
                    
                    self.baseRef.child(uid).child("isValidated").setValue(true, withCompletionBlock: { (error, ref) in
                        if let error = error {
                            RosterService.LOGGER.error("[Validate Brothers] " + error.localizedDescription)
                            errorCount += 1
                            
                            // If this is the final brother in the loop, update the UI
                            if i == uids.count - 1 {
                                self.rosterServiceDelegate?.error(message: "An error occurred while trying to validate \(errorCount) of the \(uids.count) selected brother(s).", autoClose: false)
                            }
                        } else {
                            RosterService.LOGGER.info("[Validate Brothers] Successfully validated brother with UID: " + uid)
                            
                            // Edit locally for quick changes
                            RosterManager.sharedInstance.brothersMap[uid] = RosterManager.sharedInstance.brothersToValidate[uid]
                            RosterManager.sharedInstance.brothersToValidate.removeValue(forKey: uid)
                            
                            // If this is the final brother in the loop, update the UI
                            // if no errors, send success; otherwise send error message
                            if i == uids.count - 1 && errorCount == 0 {
                                self.rosterServiceDelegate?.updateUI(isDeleted: false)
                            } else if i == uids.count - 1 {
                                RosterService.LOGGER.error("[Validate Brothers] \(errorCount) out of \(uids.count) brothers failed to be validated.")
                                self.rosterServiceDelegate?.error(message: "An error occurred while trying to validate \(errorCount) of the \(uids.count) selected brother(s).", autoClose: false)
                            }
                        }
                    })
                }
            } else {
                RosterService.LOGGER.error("[Validate Brothers] \(errorCount) out of \(uids.count) brothers failed to be validated due to network connection failure.")
                self.rosterServiceDelegate?.error(message: "Check your internet connection and try again.", autoClose: true)
            }
        })
        
    }
    
    func markUserForDeletion(uid: String) {
        RosterService.LOGGER.info("[Mark Deletion] Marking brother with UID: " + uid + " as to be deleted.")
        
        // Edit database for permanent changes
        baseRef.child(uid).child("isDeleted").setValue(true, withCompletionBlock: {(error, ref) in
            if let error = error {
                RosterService.LOGGER.error("[Mark Deletion] \(error.localizedDescription)")
                self.rosterServiceDelegate?.error(message: "An error occured while trying to delete this brother.", autoClose: false)
            } else {
                RosterService.LOGGER.info("[Mark Deletion] Successfully marked brother with UID: " + uid + " to be deleted.")
                // Edit locally for quick visual changes
                RosterManager.sharedInstance.brothersMap.removeValue(forKey: uid)
                RosterManager.sharedInstance.brothersToValidate.removeValue(forKey: uid)
                self.rosterServiceDelegate?.updateUI(isDeleted: true)
            }
        })
    }
}
