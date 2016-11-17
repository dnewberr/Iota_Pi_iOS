//
//  AnnouncementsService.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/17/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation
import Firebase

public protocol AnnouncementsServiceDelegate: class {
    func updateUI(announcements: [Announcement])
}

public class AnnouncementsService {
    weak var announcementsServiceDelegate: AnnouncementsServiceDelegate?
    
    init() {}
    
    public func fetchAnnouncements() {
        let ref = FIRDatabase.database().reference().child("Announcements")
        var announcements = [Announcement]()
        
        ref.observeSingleEvent(of: .value, with:{ (snapshot) -> Void in
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                announcements.append(Announcement(dict: dict, expiration: key))
            }
            
            self.announcementsServiceDelegate?.updateUI(announcements: announcements)
        })
    }
}
