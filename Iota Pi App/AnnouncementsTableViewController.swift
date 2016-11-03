//
//  AnnouncementsTableViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/1/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import Firebase

class AnnouncementsTableViewCell: UITableViewCell {
    @IBOutlet weak var announcementTitle: UILabel!
    var announcement: Announcement!
}
class ArchivedAnnouncementsTableViewCell: UITableViewCell {
    var announcements: [Announcement]!
}
class AnnouncementsTableViewController: UITableViewController {
   // var announcements = [Double : NSDictionary]()
   // var announcementTitles = [Double]()
    var announcements = [Announcement]()
    var archivedAnnouncements = [Announcement]()
    var announcementToPass: Announcement!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let ref = FIRDatabase.database().reference().child("Announcements")

        ref.observeSingleEvent(of: .value, with:{ (snapshot) -> Void in
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                let currentAnnouncement = Announcement(dict: dict, expiration: key)
                if (currentAnnouncement.archived) {
                    self.archivedAnnouncements.append(currentAnnouncement)
                } else {
                    self.announcements.append(currentAnnouncement)
                }
            }
            
            self.tableView.reloadData()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archivedAnnouncements.count > 0 ? announcements.count + 1 : announcements.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row > announcements.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "archivedAnnouncementCell", for: indexPath) as! ArchivedAnnouncementsTableViewCell
            
            cell.announcements = archivedAnnouncements
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "announcementCell", for: indexPath) as! AnnouncementsTableViewCell

            cell.announcement = announcements[indexPath.row]
            cell.announcementTitle.text = cell.announcement.title
        
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! AnnouncementsTableViewCell
        announcementToPass = currentCell.announcement
        
        performSegue(withIdentifier: "announcementDetailsSegue", sender: self)
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "announcementDetailsSegue") {
            let destination = segue.destination as! AnnouncementDetailsViewController
            destination.announcement = announcementToPass
        }
    }
}
