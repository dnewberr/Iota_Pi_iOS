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
}
