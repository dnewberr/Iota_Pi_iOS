//
//  VotingViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/16/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class VotingViewController: UIViewController, VotingServiceDelegate {
    let votingService = VotingService()
    var currentHirlyTopic: VotingTopic!
    
    @IBAction func createVote(_ sender: AnyObject) {
        let voteTypeSelection = SCLAlertView()
        //let hirlyButton = 
        voteTypeSelection.addButton("HIRLy", action: {
            print("HIRLY")
            self.createVoteAlert(title: "Create HIRLy Form", subtitle: "HIRLy nominations close seven days after creation.", isHirly: true)
        })
        voteTypeSelection.addButton("Current",  action: {
            print("CURRENT")
            self.createVoteAlert(title: "New Current Vote", subtitle: "Current votes close automatically after 15 minutes.", isHirly: false)
        })
        voteTypeSelection.showWarning("Create Vote", subTitle: "Select the type of vote you would like to create.\nNOTE: if the type you select already has an outstanding topic, that topic will be replaced with the newly created one.", closeButtonTitle: "Cancel")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        votingService.votingServiceDelegate = self
        votingService.fetchHirlyTopic()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateUI(topic: VotingTopic) {
        self.currentHirlyTopic = topic
        print("UPDATE UI")
        print(topic.toFirebaseObject())
        var subTitle = "\"" + topic.description + "\" is now open."
        if (!topic.sessionCode.isEmpty) {
            subTitle += " Session code: " + topic.sessionCode
        }
        SCLAlertView().showSuccess("Success!", subTitle: subTitle)
    }
    
    func confirmVote() {
        
    }
    func noCurrentVote() {
        
    }
    func denyVote() {
        
    }
    
    func createVoteAlert(title: String, subtitle: String, isHirly: Bool) {
        let voteCreation = SCLAlertView()
        let titleTextField = voteCreation.addTextField("Title")
        let descriptionTextView = voteCreation.addTextView()
        descriptionTextView.isEditable = true
        
        voteCreation.showEdit(title, subTitle: subtitle).setDismissBlock {
            if let title = titleTextField.text, let description = descriptionTextView.text {
                if title.isEmpty || description.isEmpty {
                    SCLAlertView().showError("Error", subTitle: "Please enter a title and a description for the voting topic.")
                } else {
                    print(String(format: "TITLE: %s, DESCRIPTION: %s", title, description))
                    //self.announcementsService.pushAnnouncement(title: title, details: description)
                    isHirly ? self.votingService.pushHirlyNom(title: title, description: description) : self.votingService.pushCurrentVote(title: title, description: description)
                    //SCLAlertView().showSuccess("Success!", subTitle: "\"" + title + "\" is now open.")
                }
            }
        }
    }
}
