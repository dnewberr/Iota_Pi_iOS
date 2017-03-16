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
    let baseRef = FIRDatabase.database().reference().child("Announcements")
    
    init() {}
    
    public func fetchAnnouncements() {
        baseRef.observe(.value, with:{ (snapshot) -> Void in
            var announcements = [Announcement]()
            
            for item in snapshot.children {
                if let child = item as? FIRDataSnapshot {
                    if let key = Double(child.key) {
                        if let dict = child.value as? NSDictionary {
                            let currentAnnouncement = Announcement(dict: dict, expiration: key)
                            
                            if currentAnnouncement.isArchived && Utilities.isOlderThanOneYear(date: currentAnnouncement.expirationDate) {
                                AnnouncementsService.LOGGER.info("[Fetch Announcements] Removing announcement older than one year: \(currentAnnouncement.getId()) | \(currentAnnouncement.expirationDate)")
                                self.deleteAnnouncement(id: currentAnnouncement.getId(), announcements: [])
                            } else if !announcements.contains(currentAnnouncement) {
                                announcements.append(currentAnnouncement)
                                AnnouncementsService.LOGGER.info("[Fetch Announcements] \(currentAnnouncement.toFirebaseObject())")
                            }
                        }
                    }
                }
            }
            
            AnnouncementsService.LOGGER.info("[Fetch Announcements] Retrieved " + String(announcements.count) + " announcements.")
            self.announcementsServiceDelegate?.updateUI(announcements: announcements)
        })
    }
    
    public func pushAnnouncement(title: String, details: String, tags: [String]) {
        AnnouncementsService.LOGGER.info("[Push Announcement] Pushing a new announcement.")
        let newAnnouncement = Announcement(title: title, details: details, committeeTags: tags)
        
        baseRef.child(newAnnouncement.getId()).setValue(newAnnouncement.toFirebaseObject(), withCompletionBlock: { (error, ref) in
            if let error = error {
                AnnouncementsService.LOGGER.error("[Push Announcement] " + error.localizedDescription)
                self.announcementsServiceDelegate?.error(message: "An error occurred while trying to create the announcement.")
            } else {
                AnnouncementsService.LOGGER.info("[Push Announcement] Successfully pushed new announcement with ID \(newAnnouncement.getId())")
            }
        })
    }
    
    public func deleteAnnouncement(id: String, announcements: [Announcement]) {
        AnnouncementsService.LOGGER.info("[Delete Announcement] Removing announcement with ID \(id)")
        
        baseRef.child(id).removeValue(completionBlock: { (error, ref) in
            if let error = error {
                AnnouncementsService.LOGGER.error("[Delete Announcement] " + error.localizedDescription)
                self.announcementsServiceDelegate?.error(message: "An error occurred while trying to delete the announcement.")
            } else {
                if !announcements.isEmpty {
                    self.announcementsServiceDelegate?.updateUI(announcements: announcements.filter{$0.getId() != id})
                }
            }
        })
    }
    
    public func archiveAnnouncement(id: String, announcements: [Announcement]) {
        AnnouncementsService.LOGGER.info("[Archive Announcement] Archiving announcement with ID \(id)")
        
        baseRef.child("Announcements").child(id).child("isArchived").setValue(true, withCompletionBlock: { (error, ref) in
            if let error = error {
                AnnouncementsService.LOGGER.error("[Archive Announcement] " + error.localizedDescription)
                self.announcementsServiceDelegate?.error(message: "An error occurred while trying to archive the announcement.")
            } else {
                if !announcements.isEmpty {
                    announcements.first(where: {$0.getId() == id})?.isArchived = true
                    self.announcementsServiceDelegate?.updateUI(announcements: announcements)
                }
            }
        })
    }
}
