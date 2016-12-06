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
        
       /* ref.observeSingleEvent(of: .value, with:{ (snapshot) -> Void in
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                announcements.append(Announcement(dict: dict, expiration: key))
            }
            
            self.announcementsServiceDelegate?.updateUI(announcements: announcements)
        })
        */
        ref.observe(.value, with:{ (snapshot) -> Void in
            //announcements.removeAll()
            print("NUM ITEMS IN ANNOUNCEMENTS:: " + String(announcements.count))
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                let currentAnnouncement = Announcement(dict: dict, expiration: key)
                
                if !announcements.contains(currentAnnouncement) {
                print("ADDING ANNOUNCEMENT:: "  + currentAnnouncement.title)
                    announcements.append(currentAnnouncement)
                }
            }
            
            self.announcementsServiceDelegate?.updateUI(announcements: announcements)
            
        })
        
       /* ref.observe(.childChanged, with:{ (snapshot) -> Void in
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                announcements.append(Announcement(dict: dict, expiration: key))
            }
            
            self.announcementsServiceDelegate?.updateUI(announcements: announcements)
        })*/

    }
    
    public func pushAnnouncement(title: String, details: String) {
        let ref = FIRDatabase.database().reference().child("Announcements").child(String(format:"%.0f",getDateOneWeekFromCurrent().timeIntervalSince1970))
        
        ref.setValue(Announcement(title: title, details: details).toFirebaseObject())
        //DispatchQueue.main.async {
        //ref.setValuesForKeys(["title" : title, "details" : details])
        /*ref.child("title").setValue(title)
        print("TITLE:  " + title)
        ref.child("details").setValue(details)
        print("DETAILS:  " + details)*/
        //}
    }
    
    func getDateOneWeekFromCurrent() -> Date {
        var oneWeekInterval = DateComponents()
        oneWeekInterval.day = 7
        return Calendar.current.date(byAdding: oneWeekInterval, to: Date())!
    }
}
