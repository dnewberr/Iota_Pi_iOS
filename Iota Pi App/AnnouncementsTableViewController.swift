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
import Log

class AnnouncementsTableViewCell: UITableViewCell {
    @IBOutlet weak var announcementTitle: UILabel!
    var announcement: Announcement!
}

class AnnouncementsTableViewController: UITableViewController, AnnouncementsServiceDelegate {
    @IBOutlet weak var addAnnouncementButton: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    var announcements = [Announcement]()
    var filteredAnnouncements = [Announcement]()
    var archivedAnnouncements = [Announcement]()
    var announcementToPass: Announcement!
    let announcementsService = AnnouncementsService()
    var activeFilters = [String]()
    var activeKeyphrase = ""
    var tagsToAdd = [String]()
    
    var indicator: UIActivityIndicatorView!
    
    @IBAction func addAnnouncement(_ sender: AnyObject) {
        let announcementCreation = SCLAlertView()
        announcementCreation.customSubview = createFilterSubview(isFilter: false)
        
        let titleTextField = announcementCreation.addTextField("Title")
        let descriptionTextView = announcementCreation.addTextView()
        descriptionTextView.isEditable = true
        
        announcementCreation.addButton("Create") {
            if let title = titleTextField.text, let description = descriptionTextView.text {
                if title.trim().isEmpty || description.trim().isEmpty {
                    SCLAlertView().showError("Error", subTitle: "Please enter a title and a description for the announcement.")
                } else {
                    self.announcementsService.pushAnnouncement(title: title, details: description, tags: self.tagsToAdd)
                }
            }
        }
        
        announcementCreation.showTitle(
            "Create Announcement",
            subTitle: "",
            duration: 0.0,
            completeText: "Cancel",
            style: .edit,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF)
    }
    
    @IBAction func searchForAnnouncement(_ sender: AnyObject) {
        let searchAlert = SCLAlertView()
        
        let keyphraseField = searchAlert.addTextField("Title")
        keyphraseField.autocorrectionType = .no
        keyphraseField.autocapitalizationType = .none
        keyphraseField.text = self.activeKeyphrase

        let subview = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 110))
        subview.addSubview(createFilterSubview(isFilter: true))
        searchAlert.customSubview = subview
        
        searchAlert.addButton("Search") {
            self.activeKeyphrase = keyphraseField.text!.trim().isEmpty ? "" : keyphraseField.text!.lowercased()
            self.filterAnnouncements()
        }
        
        searchAlert.showTitle(
            "Search Announcements",
            subTitle: "",
            duration: 0.0,
            completeText: "Cancel",
            style: .info,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF)
    }
    
    @IBAction func clearFilter(_ sender: Any) {
        self.activeFilters.removeAll()
        self.activeKeyphrase = ""
        self.filterAnnouncements()
    }
    
    func createFilterSubview(isFilter: Bool) -> UIView {
        let subview = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 110))
        let width = CGFloat(subview.frame.maxX / 3)
        var xVal = subview.frame.minX
        var yVal = CGFloat(10)
        
        let bandSocButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "Band Social", isFilter: isFilter)
        subview.addSubview(bandSocButton)
        
        xVal += width + 5
        
        let brotherButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "Brotherhood", isFilter: isFilter)
        subview.addSubview(brotherButton)
        
        xVal = subview.frame.minX
        yVal  = brotherButton.frame.maxY + 10
        
        let fundraisingButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "Fundraising", isFilter: isFilter)
        subview.addSubview(fundraisingButton)
        
        xVal += width + 5
        
        let musicButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "Music", isFilter: isFilter)
        subview.addSubview(musicButton)
        
        xVal = subview.frame.minX
        yVal  = musicButton.frame.maxY + 10
        
        let prButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "PR", isFilter: isFilter)
        subview.addSubview(prButton)
        
        xVal += width + 5
        
        let serviceButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "Service", isFilter: isFilter)
        subview.addSubview(serviceButton)
        
        return subview
    }
    
    func createCategoryButton(x: CGFloat, y: CGFloat, width: CGFloat, title: String, isFilter: Bool) -> UIButton {
        let height = CGFloat(25)
        
        let categoryButton = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
        categoryButton.titleLabel!.font =  UIFont(name: "HelveticaNeue", size: 12)
        categoryButton.setTitle(title, for: .normal)
        categoryButton.layer.borderColor = Style.mainColor.cgColor
        categoryButton.layer.borderWidth = 1.5
        categoryButton.layer.cornerRadius = 5
        categoryButton.setTitleColor(.black, for: .normal)
        
        if isFilter {
            if self.activeFilters.contains(title) {
                categoryButton.isSelected = true
                categoryButton.backgroundColor = Style.tintColor
            }
            
            categoryButton.addTarget(self, action: #selector(self.categoryChosen), for: .touchUpInside)
        } else {
            categoryButton.addTarget(self, action: #selector(self.addTag), for: .touchUpInside)
        }
        
        categoryButton.setTitleColor(.white, for: .selected)
        
        return categoryButton
    }
    
    func categoryChosen(sender: UIButton!) {
        let indexOfFilter = self.activeFilters.index(of: (sender.titleLabel!.text)!)
        if indexOfFilter != nil {
            self.activeFilters.remove(at: indexOfFilter!)
            sender.backgroundColor = UIColor.white
            sender.isSelected = false
        } else {
            self.activeFilters.append((sender.titleLabel!.text)!)
            sender.backgroundColor = Style.tintColor
            sender.isSelected = true
        }
    }
    
    func addTag(sender: UIButton!) {
        let indexOfFilter = self.tagsToAdd.index(of: (sender.titleLabel!.text)!)
        if indexOfFilter != nil {
            self.tagsToAdd.remove(at: indexOfFilter!)
            sender.backgroundColor = UIColor.white
            sender.isSelected = false
        } else {
            self.tagsToAdd.append((sender.titleLabel!.text)!)
            sender.backgroundColor = Style.tintColor
            sender.isSelected = true
        }
    }
    
    func filterAnnouncements() {
        self.filteredAnnouncements.removeAll()
        
        if self.activeKeyphrase.isEmpty && self.activeFilters.isEmpty {
            self.filteredAnnouncements = self.announcements
            self.clearButton.isEnabled = false
            self.clearButton.tintColor = UIColor.clear
        } else {
            self.clearButton.isEnabled = true
            self.clearButton.tintColor = nil
            
            if !self.activeFilters.isEmpty {
                for committeeTag in self.activeFilters {
                    for announcement in self.announcements {
                        if announcement.committeeTags.contains(committeeTag) && !filteredAnnouncements.contains(announcement) {
                            self.filteredAnnouncements.append(announcement)
                        }
                    }
                }
            }
            
            if !self.activeKeyphrase.isEmpty {
                let prevfilteredAnnouncements = self.filteredAnnouncements
                self.filteredAnnouncements.removeAll()
                for announcement in prevfilteredAnnouncements {
                    if (announcement.title.lowercased().contains(self.activeKeyphrase)
                        || announcement.details.lowercased().contains(self.activeKeyphrase))
                        && !filteredAnnouncements.contains(announcement) {
                        filteredAnnouncements.append(announcement)
                    }
                }
            }
            
        }
        
        self.filteredAnnouncements = self.filteredAnnouncements.sorted(by: {$0.getId() > $1.getId()})
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearButton.isEnabled = false
        self.clearButton.tintColor = UIColor.clear
        
        if RosterManager.sharedInstance.currentUserCanCreateAnnouncements() {
            self.addAnnouncementButton.isEnabled = true
            self.addAnnouncementButton.tintColor = nil
        } else {
            self.addAnnouncementButton.isEnabled = false
            self.addAnnouncementButton.tintColor = UIColor.clear
        }
        
        self.tableView.tableFooterView = UIView()
        self.indicator = Utilities.createActivityIndicator(center: self.parent!.view.center)
        self.parent!.view.addSubview(indicator)
        
        self.refreshControl?.addTarget(self, action: #selector(ArchivedVoteTableViewController.refresh), for: UIControlEvents.valueChanged)
        
        self.indicator.startAnimating()
        announcementsService.announcementsServiceDelegate = self
        announcementsService.fetchAnnouncements()
    }
    
    func refresh() {
        announcementsService.fetchAnnouncements()
    }
    
    func updateUI(announcements: [Announcement]) {
        self.announcements.removeAll()
        self.archivedAnnouncements.removeAll()
        
        for announcement in announcements {
            if announcement.isArchived {
                self.archivedAnnouncements.insert(announcement, at: 0)
            } else {
                self.announcements.insert(announcement, at: 0)
            }
        }
        
        self.filterAnnouncements()
        self.indicator.stopAnimating()
        
        if (self.refreshControl?.isRefreshing)! {
            self.refreshControl?.endRefreshing()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if !self.filteredAnnouncements.isEmpty {
            tableView.backgroundView = nil
            return 1
        } else {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No data available"
            noDataLabel.textColor = Style.tintColor
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archivedAnnouncements.count > 0 ? filteredAnnouncements.count + 1 : filteredAnnouncements.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= filteredAnnouncements.count {
            return tableView.dequeueReusableCell(withIdentifier: "archivedAnnouncementCell", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "announcementCell", for: indexPath) as!    AnnouncementsTableViewCell

        cell.announcement = filteredAnnouncements[indexPath.row]
        cell.textLabel!.text = cell.announcement.title
        cell.detailTextLabel!.text = cell.announcement.getCommitteeTagList()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= filteredAnnouncements.count {
            performSegue(withIdentifier: "archivedAnnouncementsSegue", sender: self)
        } else {
            let currentCell = tableView.cellForRow(at: indexPath) as! AnnouncementsTableViewCell
            announcementToPass = currentCell.announcement
            performSegue(withIdentifier: "announcementDetailsSegue", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < filteredAnnouncements.count
    }
 
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let deleteAnnouncementAlert = SCLAlertView()
            deleteAnnouncementAlert.addButton("Delete") {
                self.indicator.startAnimating()
                let allAnnouncements = self.announcements + self.archivedAnnouncements
                self.announcementsService.deleteAnnouncement(id: self.filteredAnnouncements[indexPath.row].getId(), announcements: allAnnouncements)
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
        
        let archive = UITableViewRowAction(style: .normal, title: "Archive") { (action, indexPath) in
            let archiveAnnouncementAlert = SCLAlertView()
            archiveAnnouncementAlert.addButton("Archive") {
                self.indicator.startAnimating()
                let allAnnouncements = self.announcements + self.archivedAnnouncements
                self.announcementsService.archiveAnnouncement(id: self.filteredAnnouncements[indexPath.row].getId(), announcements: allAnnouncements)
            }
            
            archiveAnnouncementAlert.showTitle(
                "Archive Announcement",
                subTitle: "Do you want to archive this announcement?",
                duration: 0.0,
                completeText: "Cancel",
                style: .warning,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF)
        }
        
        archive.backgroundColor = UIColor.gray
        
        return [delete, archive]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "announcementDetailsSegue" {
            let destination = segue.destination as! AnnouncementDetailsViewController
            destination.announcement = self.announcementToPass
        }
        if segue.identifier == "archivedAnnouncementsSegue" {
            let destination = segue.destination as! ArchivedAnnouncementsTableViewController
            destination.announcements = archivedAnnouncements
        }
    }
    
    func error(message: String) {
        SCLAlertView().showError("Error", subTitle: message)
    }
}
