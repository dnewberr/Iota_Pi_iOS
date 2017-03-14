//
//  ArchivedHirlyDetailViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 3/13/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit

class ArchivedHirlyDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var currentHirlyVote: VotingTopic!
    var winners: [String]!
    var chosenWinnerId: String!
    var chosenWinnerName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.winners = Array(self.currentHirlyVote.winners.keys)
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
        self.chosenWinnerName = tableView.cellForRow(at: indexPath)?.textLabel?.text
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reasonsSegue" {
            let destination = segue.destination as! ReasonsTableViewController
            destination.winnerId = self.chosenWinnerId
            destination.winnerName = self.chosenWinnerName
        }
    }
}
