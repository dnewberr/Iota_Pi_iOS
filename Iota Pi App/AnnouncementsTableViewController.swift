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
    var announcementsToShow = [Announcement]()
    var archivedAnnouncements = [Announcement]()
    var announcementToPass: Announcement!
    let announcementsService = AnnouncementsService()
    var activeFilters = [String]()
    var activeKeyphrase: String?
    var tagsToAdd = [String]()
    
    var indicator = UIActivityIndicatorView()
    
    @IBAction func addAnnouncement(_ sender: AnyObject) {
        let announcementCreation = SCLAlertView()
        let titleTextField = announcementCreation.addTextField("Title")
        let descriptionTextView = announcementCreation.addTextView()
        descriptionTextView.isEditable = true
        
        // Tag subview
        let subview = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 110))
        var xVal = subview.frame.minX
        
        let width = CGFloat(subview.frame.maxX / 3)
        
        var yVal = CGFloat(10)
        
        let bandSocButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "Band Social", isFilter: false)
        subview.addSubview(bandSocButton)
        
        xVal += width + 5
        
        let brotherButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "Brotherhood", isFilter: false)
        subview.addSubview(brotherButton)
        
        xVal = subview.frame.minX
        yVal  = brotherButton.frame.maxY + 10
        
        let fundraisingButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "Fundraising", isFilter: false)
        subview.addSubview(fundraisingButton)
        
        xVal += width + 5
        
        let musicButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "Music", isFilter: false)
        subview.addSubview(musicButton)
        
        xVal = subview.frame.minX
        yVal  = musicButton.frame.maxY + 10
        
        let prButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "PR", isFilter: false)
        subview.addSubview(prButton)
        
        xVal += width + 5
        
        let serviceButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "Service", isFilter: false)
        subview.addSubview(serviceButton)
        
        // Add the subview to the alert's UI property
        announcementCreation.customSubview = subview
        
        announcementCreation.showEdit("Create Announcement", subTitle: "Announcements expire seven days after creation.").setDismissBlock {
            if let title = titleTextField.text, let description = descriptionTextView.text {
                if title.isEmpty || description.isEmpty {
                    SCLAlertView().showError("Error", subTitle: "Please enter a title and a description for the announcement.")
                } else {
                    self.announcementsService.pushAnnouncement(title: title, details: description, tags: self.tagsToAdd)
                }
            }
        }
    }
    
    @IBAction func searchForAnnouncement(_ sender: AnyObject) {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue", size: 14)!,
            showCloseButton: false
        )
        
        // Initialize SCLAlertView using custom Appearance
        let alert = SCLAlertView(appearance: appearance)
        
        // Create the subview
        let subview = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
        var xVal = subview.frame.minX
        
        // Add textfield 1
        let keyphraseField = UITextField(frame: CGRect(x: xVal, y: 10, width: 205, height: 25))
        keyphraseField.layer.borderColor = UIColor.blue.cgColor
        keyphraseField.layer.borderWidth = 1.5
        keyphraseField.layer.cornerRadius = 5
        keyphraseField.placeholder = "Keyphrase"
        keyphraseField.textAlignment = NSTextAlignment.center
        subview.addSubview(keyphraseField)
        
        let width = CGFloat(subview.frame.maxX / 3)
        
        var yVal = keyphraseField.frame.maxY + 10
        
        let bandSocButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "Band Social", isFilter: true)
        subview.addSubview(bandSocButton)
        
        xVal += width + 5
        
        let brotherButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "Brotherhood", isFilter: true)
        subview.addSubview(brotherButton)
        
        xVal = subview.frame.minX
        yVal  = brotherButton.frame.maxY + 10
        
        let fundraisingButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "Fundraising", isFilter: true)
        subview.addSubview(fundraisingButton)
        
        xVal += width + 5
        
        let musicButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "Music", isFilter: true)
        subview.addSubview(musicButton)
        
        xVal = subview.frame.minX
        yVal  = musicButton.frame.maxY + 10
        
        let prButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "PR", isFilter: true)
        subview.addSubview(prButton)
        
        xVal += width + 5
        
        let serviceButton = createCategoryButton(x: xVal, y: yVal, width: width, title: "Service", isFilter: true)
        subview.addSubview(serviceButton)
        
        // Add the subview to the alert's UI property
        alert.customSubview = subview
        alert.addButton("Search") {
            self.activeKeyphrase = keyphraseField.text!.isEmpty ? nil : keyphraseField.text
            self.filterAnnouncements()
        }
        
        alert.showInfo("Search", subTitle: "")
        
    }
    
    func createCategoryButton(x: CGFloat, y: CGFloat, width: CGFloat, title: String, isFilter: Bool) -> UIButton {
        let height = CGFloat(25)
        
        let categoryButton = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
        categoryButton.titleLabel!.font =  UIFont(name: "HelveticaNeue", size: 12)
        categoryButton.setTitle(title, for: .normal)
        categoryButton.layer.borderColor = UIColor.blue.cgColor
        categoryButton.layer.borderWidth = 1.5
        categoryButton.layer.cornerRadius = 5
        categoryButton.setTitleColor(.black, for: .normal)
        
        if isFilter {
            if self.activeFilters.contains(title) {
                categoryButton.isSelected = true
                categoryButton.backgroundColor = UIColor.blue
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
            sender.backgroundColor = UIColor.blue
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
            sender.backgroundColor = UIColor.blue
            sender.isSelected = true
        }
    }
    
    func filterAnnouncements() {
        self.announcementsToShow.removeAll()
        
        if self.activeKeyphrase == nil && self.activeFilters.isEmpty {
            self.announcementsToShow = self.announcements
        } else {
            for committeeTag in self.activeFilters {
                for announcement in self.announcements {
                    if announcement.committeeTags.contains(committeeTag) && !self.announcementsToShow.contains(announcement) {
                        self.announcementsToShow.append(announcement)
                    }
                }
            }
            
            if let keyphrase = self.activeKeyphrase {
                let prevAnnouncementsToShow = self.announcementsToShow
                self.announcementsToShow.removeAll()
                for announcement in prevAnnouncementsToShow {
                    if (announcement.title.contains(keyphrase) || announcement.details.contains(keyphrase))
                        && !announcementsToShow.contains(announcement) {
                        announcementsToShow.append(announcement)
                    }
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.indicator = Utilities.createActivityIndicator(center: self.parent!.view.center)
        self.parent!.view.addSubview(indicator)
        
        self.indicator.startAnimating()
        announcementsService.announcementsServiceDelegate = self
        announcementsService.fetchAnnouncements()
    }
    
    func updateUI(announcements: [Announcement]) {
        self.announcements.removeAll()
        self.archivedAnnouncements.removeAll()
        
        for announcement in announcements {
            if announcement.archived {
                self.archivedAnnouncements.insert(announcement, at: 0)
            } else {
                self.announcements.insert(announcement, at: 0)
            }
        }
        
        self.filterAnnouncements()
        self.indicator.stopAnimating()
        
        if (RosterManager.sharedInstance.currentUserCanCreateAnnouncements()) {
            self.addAnnouncementButton.isEnabled = true
            self.addAnnouncementButton.tintColor = nil
        } else {
            self.addAnnouncementButton.isEnabled = false
            self.addAnnouncementButton.tintColor = UIColor.clear
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archivedAnnouncements.count > 0 ? announcementsToShow.count + 1 : announcementsToShow.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row >= announcementsToShow.count) {
            return tableView.dequeueReusableCell(withIdentifier: "archivedAnnouncementCell", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "announcementCell", for: indexPath) as!    AnnouncementsTableViewCell

        cell.announcement = announcementsToShow[indexPath.row]
        cell.textLabel!.text = cell.announcement.title
        cell.detailTextLabel!.text = cell.announcement.getCommitteeTagList()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row >= announcementsToShow.count) {
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
            destination.announcement = self.announcementToPass
        }
        if (segue.identifier == "archivedAnnouncementsSegue") {
            let destination = segue.destination as! ArchivedAnnouncementsTableViewController
            destination.announcements = archivedAnnouncements
        }
    }
}
