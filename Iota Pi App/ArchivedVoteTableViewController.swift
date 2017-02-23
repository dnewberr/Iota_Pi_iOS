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
    var votingTopics = [VotingTopic]()
    
    var indicator: UIActivityIndicatorView!
    var filteredTopics = [VotingTopic]()
    var filter = ""
    var isHirly = false
    
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
        
        searchAlert.showTitle(
            "Search",
            subTitle: "Enter a phrase to find a topic containing it.",
            duration: 0.0,
            completeText: "Search",
            style: .notice,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF).setDismissBlock {
            if let search = searchField.text {
                self.filter = search.lowercased()
                self.filterVotes()
            }
        }
    }
    
    func filterVotes() {
        self.filteredTopics.removeAll()
        
        if !filter.trim().isEmpty {
            if isHirly {
                self.filteredTopics = self.votingTopics.filter({
                    $0.summary.lowercased().contains(filter)
                        || $0.winners.lowercased().contains(filter)
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

    func sendArchivedTopics(topics: [VotingTopic]) {
        self.indicator.stopAnimating()
        self.votingTopics = topics
        self.filterVotes()
        
        if (self.refreshControl?.isRefreshing)! {
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if !self.filteredTopics.isEmpty {
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
        return self.filteredTopics.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "archivedVoteCell", for: indexPath)

        let cellTopic = self.filteredTopics[indexPath.row]
        if self.isHirly {
            cell.textLabel?.text = cellTopic.summary
            cell.detailTextLabel?.text = "\(Utilities.dateToDayTime(date: cellTopic.expirationDate)) | \(cellTopic.winners)"
        } else {
            cell.textLabel?.text = cellTopic.sessionCode
            cell.detailTextLabel?.text = Utilities.dateToDayTime(date: cellTopic.expirationDate)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellTopic = self.filteredTopics[indexPath.row]
        if self.isHirly {
            let hirlyDetailsAlert = SCLAlertView()
            hirlyDetailsAlert.showTitle(
                cellTopic.summary,
                subTitle: "[\(Utilities.dateToDayTime(date: cellTopic.expirationDate))]"
                    + "\nWinner(s): \(cellTopic.winners)",
                duration: 0.0,
                completeText: "Done",
                style: .info,
                colorStyle: Style.mainColorHex,
                colorTextButton: 0xFFFFFF)
        } else {
            let hirlyDetailsAlert = SCLAlertView()
            hirlyDetailsAlert.showTitle(
                cellTopic.summary,
                subTitle: "[\(Utilities.dateToDayTime(date: cellTopic.expirationDate))]"
                    + "\nYes - \(cellTopic.yesVotes)"
                    + "\nNo - \(cellTopic.noVotes)"
                    + "\nAbstain - \(cellTopic.abstainVotes)",
                duration: 0.0,
                completeText: "Done",
                style: .info,
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
