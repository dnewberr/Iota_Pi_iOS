//
//  ReasonsTableViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 3/13/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit
import SCLAlertView

class ReasonsTableViewController: UITableViewController {
    var hirlyTopic: VotingTopic!
    var reasons = [String]()
    var winnerId: String!
    var winnerName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        
        if let reasons = self.hirlyTopic.winners[self.winnerId] {
            self.reasons = reasons
        }
        
        self.title = self.winnerName
    }

    // never empty, no need to create empty data view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reasons.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reasonCell", for: indexPath)

        cell.textLabel?.text = reasons[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reasonAlert = SCLAlertView()
        let reasonText = reasonAlert.addTextView()
        reasonText.text = reasons[indexPath.row]
        reasonText.isEditable = false
        reasonText.scrollRangeToVisible(NSMakeRange(0, 0))
        
        reasonAlert.showTitle(
            self.winnerName,
            subTitle: self.hirlyTopic.summary,
            duration: 0.0,
            completeText: "Done",
            style: .info,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF)
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
