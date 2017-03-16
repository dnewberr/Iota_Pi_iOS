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

class ArchivedAnnouncementsTableViewController: UITableViewController, AnnouncementsServiceDelegate {
    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    let announcementsService = AnnouncementsService()
    var announcements = [Announcement]()
    var filteredAnnouncements = [Announcement]()
    var announcementToPass: Announcement!
    var activeKeyphrase = ""
    
    @IBAction func clearFilter(_ sender: Any) {
        self.activeKeyphrase = ""
        self.filterAnnouncements()
    }
    
    @IBAction func search(_ sender: Any) {
        let alert = SCLAlertView()
        
        let keyphraseField = alert.addTextField("Title")
        keyphraseField.autocorrectionType = .no
        keyphraseField.autocapitalizationType = .none
        keyphraseField.text = self.activeKeyphrase
        
        alert.showTitle(
            "Search",
            subTitle: "Enter a phrase to find an announcement.",
            duration: 0.0,
            completeText: "Search",
            style: .info,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF).setDismissBlock {
                self.activeKeyphrase = keyphraseField.text!.trim().isEmpty ? "" : keyphraseField.text!.lowercased()
                self.filterAnnouncements()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.announcementsService.announcementsServiceDelegate = self
        
        self.clearButton.isEnabled = false
        self.clearButton.tintColor = UIColor.clear
        
        self.tableView.tableFooterView = UIView()
        
        self.filterAnnouncements()
    }
    
    // filters announcements by the active keyphrase
    func filterAnnouncements() {
        self.filteredAnnouncements.removeAll()
        
        if self.activeKeyphrase.isEmpty {
            self.filteredAnnouncements = self.announcements
            self.clearButton.isEnabled = false
            self.clearButton.tintColor = UIColor.clear
        } else {
            self.clearButton.isEnabled = true
            self.clearButton.tintColor = nil
            
            for announcement in self.announcements {
                if (announcement.title.lowercased().contains(self.activeKeyphrase)
                    || announcement.details.lowercased().contains(self.activeKeyphrase)
                    || !announcement.committeeTags.filter{$0.lowercased().contains(self.activeKeyphrase)}.isEmpty)
                    && !filteredAnnouncements.contains(announcement) {
                    filteredAnnouncements.append(announcement)
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !self.filteredAnnouncements.isEmpty {
            tableView.backgroundView = nil
            return 1
        } else {
            tableView.backgroundView = Utilities.createNoDataLabel(message: "No announcements found.", width: tableView.bounds.size.width, height: tableView.bounds.size.height)
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAnnouncements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "archivedCell", for: indexPath)
            
        let announcement = self.filteredAnnouncements[indexPath.row]
        cell.textLabel!.text = announcement.title + " - " + Utilities.dateToDay(date: announcement.expirationDate)
        cell.detailTextLabel!.text = announcement.getCommitteeTagList()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let deleteAnnouncementAlert = SCLAlertView()
            deleteAnnouncementAlert.addButton("Delete") {
                self.announcementsService.deleteAnnouncement(id: self.filteredAnnouncements[indexPath.row].getId(), announcements: self.announcements)
            }
            
            deleteAnnouncementAlert.showTitle(
                "Delete Announcement",
                subTitle: "Are you sure you want to delete this announcement?",
                duration: 0.0,
                completeText: "Cancel",
                style: .warning,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return RosterManager.sharedInstance.currentUserCanCreateAnnouncements()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.announcementToPass = self.filteredAnnouncements[indexPath.row]
        performSegue(withIdentifier: "archivedAnnouncementDetailsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "archivedAnnouncementDetailsSegue" {
            let destination = segue.destination as! AnnouncementDetailsViewController
            destination.announcement = self.announcementToPass
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* DELEGATE METHODS */
    
    func updateUI(announcements: [Announcement]) {
        self.announcements = announcements
        self.filterAnnouncements()
    }
    
    func error(message: String) {
        SCLAlertView().showError("Error", subTitle: message)
    }
}
