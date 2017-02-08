//
//  RosterService.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 12/8/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation
import Firebase

public protocol RosterServiceDelegate: class {
    func updateUI()
    func sendMap(map: [String : User])
}

public class RosterService {
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
                
                print("Retrieved brother with UID: " + key)
            }
            
            
            self.rosterServiceDelegate?.sendMap(map: brothersMap)
        })
    }
    
    func pushBrotherDetail(brotherId: String, key: String, value: String) {
        baseRef.child(brotherId).child(key).setValue(value)
        self.rosterServiceDelegate?.updateUI()
    }
    
    func checkInBrother() {
        baseRef.child(RosterManager.sharedInstance.currentUserId).child("isCheckedIn").setValue(true)
    }
}
