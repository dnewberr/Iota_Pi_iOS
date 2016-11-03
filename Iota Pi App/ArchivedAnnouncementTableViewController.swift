//
//  AnnouncementsTableViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/1/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import Firebase

class ArchivedTableViewCell: UITableViewCell {
    @IBOutlet weak var announcementTitle: UILabel!
    var announcement: Announcement!
}

class ArchivedAnnouncementsTableViewController: UITableViewController {
    var announcements = [Announcement]()
    var announcementToPass: Announcement!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return announcements.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "archivedCell", for: indexPath) as! ArchivedTableViewCell
            
        cell.announcement = announcements[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        cell.announcementTitle.text = cell.announcement.title + " - " + dateFormatter.string(from: cell.announcement.expirationDate)
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! ArchivedTableViewCell
        announcementToPass = currentCell.announcement
        
        performSegue(withIdentifier: "archivedAnnouncementDetailsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "archivedAnnouncementDetailsSegue") {
            let destination = segue.destination as! AnnouncementDetailsViewController
            destination.announcement = announcementToPass
        }
    }
}
