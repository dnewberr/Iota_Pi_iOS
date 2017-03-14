//
//  ArchivedHirlyDetailViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 3/13/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit

class ArchivedHirlyDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var dateEndedLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var winnersTableView: UITableView!
    
    var currentHirlyTopic: VotingTopic!
    var winners: [String]!
    var chosenWinnerId: String!
    var chosenWinnerName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.winners = Array(self.currentHirlyTopic.winners.keys)
        self.dateEndedLabel.text = Utilities.dateToDayTime(date: self.currentHirlyTopic.expirationDate)
        self.valueLabel.text = self.currentHirlyTopic.summary
        self.winnersTableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "winnerCell", for: indexPath)
        
        if let brother = RosterManager.sharedInstance.brothersMap[winners[indexPath.row]] {
            cell.textLabel?.text = "\(brother.firstname!) \(brother.lastname!)"
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.winners.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chosenWinnerId = self.winners[indexPath.row]
        self.chosenWinnerName = tableView.cellForRow(at: indexPath)?.textLabel?.text!
        self.performSegue(withIdentifier: "reasonsSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reasonsSegue" {
            let destination = segue.destination as! ReasonsTableViewController
            destination.winnerId = self.chosenWinnerId
            destination.winnerName = self.chosenWinnerName
            destination.hirlyTopic = self.currentHirlyTopic
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !self.winners.isEmpty {
            tableView.backgroundView = nil
            return 1
        } else {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No Winners"
            noDataLabel.textColor = Style.tintColor
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
            return 0
        }
    }
}
