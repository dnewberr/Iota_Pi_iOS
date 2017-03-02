//
//  AnnouncementsService.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/17/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation
import Firebase
import Log

public protocol AnnouncementsServiceDelegate: class {
    func updateUI(announcements: [Announcement])
    func error(message: String)
}

public class AnnouncementsService {
    public static let LOGGER = Logger(formatter: Formatter("📣 [%@] %@ %@: %@", .date("dd/MM/yy HH:mm"), .location, .level, .message), theme: nil, minLevel: .trace)
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
                    AnnouncementsService.LOGGER.info("[Fetch Announcements] \(currentAnnouncement.toFirebaseObject())")
                }
            }
            
            AnnouncementsService.LOGGER.info("[Fetch Announcements] Retrieved " + String(announcements.count) + " announcements.")
            self.announcementsServiceDelegate?.updateUI(announcements: announcements)
        })
    }
    
    public func pushAnnouncement(title: String, details: String, tags: [String]) {
        let newAnnouncement = Announcement(title: title, details: details, committeeTags: tags)
        let ref = FIRDatabase.database().reference().child("Announcements").child(newAnnouncement.getId())
        
        AnnouncementsService.LOGGER.info("[Push Announcement] \(newAnnouncement.toFirebaseObject())")
        ref.setValue(newAnnouncement.toFirebaseObject())
    }
    
    public func deleteAnnouncement(id: String, announcements: [Announcement]) {
        AnnouncementsService.LOGGER.info("[Delete Announcement] Removing announcement with ID \(id)")
        FIRDatabase.database().reference().child("Announcements").child(id).removeValue(completionBlock: { (error, ref) in
            if let error = error {
                AnnouncementsService.LOGGER.error("[Delete Announcement] " + error.localizedDescription)
                self.announcementsServiceDelegate?.error(message: "An error occurred while trying to delete the announcement.")
            } else {
                self.announcementsServiceDelegate?.updateUI(announcements: announcements.filter{$0.getId() != id})
            }
        })
    }
}
