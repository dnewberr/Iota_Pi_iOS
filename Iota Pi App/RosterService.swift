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
}

public class RosterService {
    weak var rosterServiceDelegate: RosterServiceDelegate?
    let baseRef = FIRDatabase.database().reference().child("Brothers")
    
    init() {}
    
    func pushBrotherDetail(brotherId: String, key: String, value: String) {
        baseRef.child(brotherId).child(key).setValue(value)
        self.rosterServiceDelegate?.updateUI()
    }
}
