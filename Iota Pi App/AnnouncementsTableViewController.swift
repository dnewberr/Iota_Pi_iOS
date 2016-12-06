//
//  AnnouncementsTableViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/1/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
class AnnouncementsTableViewCell: UITableViewCell {
    @IBOutlet weak var announcementTitle: UILabel!
    var announcement: Announcement!
}

class AnnouncementsTableViewController: UITableViewController, AnnouncementsServiceDelegate {
    @IBOutlet weak var addAnnouncementButton: UIBarButtonItem!
    var announcements = [Announcement]()
    var archivedAnnouncements = [Announcement]()
    var announcementToPass: Announcement!
    
    let announcementsService = AnnouncementsService()
    
    @IBAction func addAnnouncement(_ sender: AnyObject) {
        let announcementCreation = SCLAlertView()
        let titleTextField = announcementCreation.addTextField("Title")
        let descriptionTextView = announcementCreation.addTextView()
        descriptionTextView.isEditable = true

        
        announcementCreation.showEdit("Create Announcement", subTitle: "Announcements expire seven days after creation.").setDismissBlock {
            if let title = titleTextField.text, let description = descriptionTextView.text {
                if title.isEmpty || description.isEmpty {
                    SCLAlertView().showError("Error", subTitle: "Please enter a title and a description for the announcement.")
                } else {
                    self.announcementsService.pushAnnouncement(title: title, details: description)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if RosterManager.sharedInstance.currentUserCanCreateAnnouncements() {
            self.addAnnouncementButton.isEnabled = true
        } else {
            self.addAnnouncementButton.isEnabled = false
        }
        
        announcementsService.announcementsServiceDelegate = self
        announcementsService.fetchAnnouncements()
    }
    
    func updateUI(announcements: [Announcement]) {
        for announcement in announcements {
            if (announcement.archived) {
                self.archivedAnnouncements.append(announcement)
            } else {
                self.announcements.append(announcement)
            }
        }
        
        self.tableView.reloadData()
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
        if (indexPath.row >= announcements.count) {
           // let cell = tableView.dequeueReusableCell(withIdentifier: "archivedAnnouncementCell", for: indexPath)
            
            
            //cell.announcementTitle.text = "Archived"
            
            return tableView.dequeueReusableCell(withIdentifier: "archivedAnnouncementCell", for: indexPath)
        }
        print("REGULAR!!!!")
        let cell = tableView.dequeueReusableCell(withIdentifier: "announcementCell", for: indexPath) as!    AnnouncementsTableViewCell

        cell.announcement = announcements[indexPath.row]
        cell.announcementTitle.text = cell.announcement.title
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row >= announcements.count) {
            performSegue(withIdentifier: "archivedAnnouncementsSegue", sender: self)
        } else {
            let currentCell = tableView.cellForRow(at: indexPath) as! AnnouncementsTableViewCell
            announcementToPass = currentCell.announcement
        
            performSegue(withIdentifier: "announcementDetailsSegue", sender: self)
        }
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "announcementDetailsSegue") {
            let destination = segue.destination as! AnnouncementDetailsViewController
            destination.announcement = announcementToPass
        }
        if (segue.identifier == "archivedAnnouncementsSegue") {
            let destination = segue.destination as! ArchivedAnnouncementsTableViewController
            destination.announcements = archivedAnnouncements
        }
    }
}
