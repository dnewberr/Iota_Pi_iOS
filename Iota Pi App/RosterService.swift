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
    func updateUI()
    func sendMap(map: [String : User])
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
        
        baseRef.child(brotherId).child(key).setValue(value)
        self.rosterServiceDelegate?.updateUI()
    }
    x
    func validateBrothers(uids: [String]) {
        for uid in uids {
            RosterService.LOGGER.info("[Validate Brothers] Validated brother with UID: " + uid)
            baseRef.child(uid).child("isValidated").setValue(true)
        }
        
        self.rosterServiceDelegate?.updateUI()
    }
}
