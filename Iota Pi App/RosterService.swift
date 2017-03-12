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
    func error(message: String)
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
                self.rosterServiceDelegate?.error(message: "An error has occured that prevents your changes from being saved.")
            } else {
                self.rosterServiceDelegate?.updateUI(isDeleted: false)
            }
        })
    }
    
    func validateBrothers(uids: [String]) {
        for uid in uids {
            RosterService.LOGGER.info("[Validate Brothers] Validated brother with UID: " + uid)
            
            // Edit database for permanent changes
            baseRef.child(uid).child("isValidated").setValue(true)
            
            // Edit locally for quick changes
            RosterManager.sharedInstance.brothersMap[uid] = RosterManager.sharedInstance.brothersToValidate[uid]
            RosterManager.sharedInstance.brothersToValidate.removeValue(forKey: uid)
        }
        
        self.rosterServiceDelegate?.updateUI(isDeleted: false)
    }
    
    func markUserForDeletion(uid: String) {
        RosterService.LOGGER.info("[Mark Deletion] Marking brother with UID: " + uid + " as to be deleted.")
        
        // Edit database for permanent changes
        baseRef.child(uid).child("isDeleted").setValue(true, withCompletionBlock: {(error, ref) in
            if let error = error {
                RosterService.LOGGER.info("[Mark Deletion] \(error.localizedDescription)")
                self.rosterServiceDelegate?.error(message: "An error has occured that prevents your changes from being saved.")
            } else {
                // Edit locally for quick visual changes
                RosterManager.sharedInstance.brothersMap.removeValue(forKey: uid)
                self.rosterServiceDelegate?.updateUI(isDeleted: true)
            }
        })
    }
}
