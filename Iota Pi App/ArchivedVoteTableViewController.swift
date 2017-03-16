//
//  ArchivedVoteTableViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 2/21/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit
import SCLAlertView

class ArchivedVoteTableViewController: UITableViewController, VotingServiceDelegate {
    @IBOutlet weak var clearFilterButton: UIBarButtonItem!
    
    let votingService = VotingService()
    var chosenHirlyTopic: VotingTopic!
    var filteredTopics = [VotingTopic]()
    var filter = ""
    var isHirly = false
    var indicator: UIActivityIndicatorView!
    var votingTopics = [VotingTopic]()
    
    @IBAction func clearFilter(_ sender: AnyObject) {
        self.filter = ""
        self.filterVotes()
    }
    
    @IBAction func search(_ sender: AnyObject) {
        let searchAlert = SCLAlertView()
        let searchField = searchAlert.addTextField()
        searchField.autocapitalizationType = .none
        searchField.autocorrectionType = .no
        searchField.placeholder = "Keyphrase"
        
        searchAlert.addButton("Search") {
            self.filter = searchField.text!.trim().lowercased()
            self.filterVotes()
        }
        
        searchAlert.showTitle(
            "Search",
            subTitle: "Enter a phrase to find a topic containing it.",
            duration: 0.0,
            completeText: "Cancel",
            style: .notice,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.votingService.votingServiceDelegate = self
        self.tableView.tableFooterView = UIView()
        
        self.clearFilterButton.isEnabled = false
        self.clearFilterButton.tintColor = UIColor.clear
        
        self.indicator = Utilities.createActivityIndicator(center: self.parent!.view.center)
        self.parent!.view.addSubview(indicator)
    
        self.refreshControl?.addTarget(self, action: #selector(ArchivedVoteTableViewController.refresh), for: UIControlEvents.valueChanged)
        
        self.indicator.startAnimating()
        self.votingService.fetchArchivedVotingTopics(isHirly: self.isHirly)
    }
    
    func refresh() {
        self.votingService.fetchArchivedVotingTopics(isHirly: self.isHirly)
    }
    
    func filterVotes() {
        self.filteredTopics.removeAll()
        
        if !self.filter.trim().isEmpty {
            if isHirly {
                self.filteredTopics = self.votingTopics.filter({
                    $0.summary.lowercased().contains(filter)
                        || $0.getWinnerNames().lowercased().contains(filter)
                        || $0.description.lowercased().contains(filter)
                        || Utilities.dateToDayTime(date: $0.expirationDate).contains(filter)
                })
            } else {
                self.filteredTopics = self.votingTopics.filter({
                    $0.summary.lowercased().contains(filter)
                        || $0.description.lowercased().contains(filter)
                        || $0.sessionCode.lowercased().contains(filter)
                        || Utilities.dateToDayTime(date: $0.expirationDate).contains(filter)
                })
            }
            
            self.clearFilterButton.isEnabled = true
            self.clearFilterButton.tintColor = nil
        } else {
            self.filteredTopics = self.votingTopics
            self.clearFilterButton.isEnabled = false
            self.clearFilterButton.tintColor = UIColor.clear
        }
        
        self.filteredTopics = self.filteredTopics.sorted(by: {$0.expirationDate > $1.expirationDate})
        self.tableView.reloadData()
    }
    
    func calculatePercentage(dividend: Int, divisor: Int) -> String {
        return String(format: "%d/%d [%.0f%%]", dividend, divisor, (Float(dividend)/Float(divisor) * 100))
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !self.filteredTopics.isEmpty {
            tableView.backgroundView = nil
            return 1
        } else {
            tableView.backgroundView = Utilities.createNoDataLabel(message: "No votes found.", width: tableView.bounds.size.width, height: tableView.bounds.size.height)
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredTopics.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "archivedVoteCell", for: indexPath)

        let cellTopic = self.filteredTopics[indexPath.row]
        cell.textLabel?.text = cellTopic.summary
        
        if self.isHirly {
            cell.detailTextLabel?.text = "\(Utilities.dateToDayTime(date: cellTopic.expirationDate)) | \(cellTopic.getWinnerNames())"
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.detailTextLabel?.text = Utilities.dateToDayTime(date: cellTopic.expirationDate)
            cell.accessoryType = .detailButton
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellTopic = self.filteredTopics[indexPath.row]
        if self.isHirly {
            self.chosenHirlyTopic = cellTopic
            performSegue(withIdentifier: "archivedHirlySegue", sender: self)
        } else {
            let totalVotes = cellTopic.yesVotes + cellTopic.noVotes + cellTopic.abstainVotes
            let results = totalVotes > 0
                ?   "\n\nYes - \(calculatePercentage(dividend: cellTopic.yesVotes, divisor: totalVotes))"
                    + "\nNo - \(calculatePercentage(dividend: cellTopic.noVotes, divisor: totalVotes))"
                    + "\nAbstain - \(calculatePercentage(dividend: cellTopic.abstainVotes, divisor: totalVotes))"
                : "\n\nNo Votes Recorded"
            
            let hirlyDetailsAlert = SCLAlertView()
            hirlyDetailsAlert.showTitle(
                cellTopic.summary,
                subTitle: cellTopic.description + results,
                duration: 0.0,
                completeText: "Done",
                style: .info,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF)
        
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isHirly {
            return RosterManager.sharedInstance.currentUserCanCreateHirly()
        } else {
            return RosterManager.sharedInstance.currentUserCanCreateVote()
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let deleteVoteAlert = SCLAlertView()
            deleteVoteAlert.addButton("Delete") {
                self.indicator.startAnimating()
                self.votingService.deleteVote(id: self.filteredTopics[indexPath.row].getId(), topics: self.votingTopics, isHirly: self.isHirly, isShown: false)
            }
            
            deleteVoteAlert.showTitle(
                "Delete Vote",
                subTitle: "Are you sure you want to delete this vote?",
                duration: 0.0,
                completeText: "Cancel",
                style: .warning,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "archivedHirlySegue" {
            let destination = segue.destination as! ArchivedHirlyDetailViewController
            destination.currentHirlyTopic = self.chosenHirlyTopic
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* DELEGATE METHODS */
    func sendArchivedTopics(topics: [VotingTopic]) {
        self.indicator.stopAnimating()
        self.votingTopics = topics
        self.filterVotes()
        
        if (self.refreshControl?.isRefreshing)! {
            self.refreshControl?.endRefreshing()
        }
    }
    
    func showMessage(message: String, title: String, isError: Bool) {
        if isError {
            SCLAlertView().showError(title, subTitle: message)
        } else {
            SCLAlertView().showTitle(
                title,
                subTitle: message,
                duration: 0.0,
                completeText: "Cancel",
                style: .warning,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF)
        }
    }
    
    // unnecessary delegate methods
    func updateUI(topic: VotingTopic) {}
    func confirmVote() {}
    func noCurrentVote(isHirly: Bool) {}
    func denyVote(isHirly: Bool, topic: VotingTopic?) {}
}
