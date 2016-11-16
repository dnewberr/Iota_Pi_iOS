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
    var brothersMap = [String : User]()
    
    init() {
        let ref = FIRDatabase.database().reference().child("Brothers")
        
        ref.observeSingleEvent(of: .value, with:{ (snapshot) -> Void in
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = child.key as! String
                let dict = child.value as! NSDictionary
                brothersMap[key] = User(dict: dict, userId: key)
            }
        })
    }
}
