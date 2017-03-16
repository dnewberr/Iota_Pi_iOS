//
//  AnnouncementDetailsViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/3/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit

class AnnouncementDetailsViewController: UIViewController {
    var announcement: Announcement!
    
    @IBOutlet weak var committeeTagLabel: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.detailTextView.text = self.announcement.details
        self.detailTextView.layer.borderWidth = 0
        
        self.committeeTagLabel.text = self.announcement.getCommitteeTagList()
        self.expirationDateLabel.text = "Expires: " + Utilities.dateToDay(date: self.announcement.expirationDate)
        self.titleLabel.text = self.announcement.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
