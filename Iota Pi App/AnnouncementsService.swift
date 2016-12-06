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
        
        ref.observe(.value, with:{ (snapshot) -> Void in
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                let currentAnnouncement = Announcement(dict: dict, expiration: key)
                
                if !announcements.contains(currentAnnouncement) {
                    announcements.append(currentAnnouncement)
                }
            }
            
            self.announcementsServiceDelegate?.updateUI(announcements: announcements)
        })
    }
    
    public func pushAnnouncement(title: String, details: String) {
        let newAnnouncement = Announcement(title: title, details: details)
        let ref = FIRDatabase.database().reference().child("Announcements").child(newAnnouncement.getId())
        
        ref.setValue(newAnnouncement.toFirebaseObject())
    }
}
