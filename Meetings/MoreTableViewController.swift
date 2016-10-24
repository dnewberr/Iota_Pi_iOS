//
//  MoreTableViewController.swift
//  Meetings
//
//  Created by Deborah Newberry on 10/24/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit

class MoreTableCellView: UITableViewCell {
    @IBOutlet weak var moreCellLabel: UILabel!
}

class MoreTableViewController: UITableViewController {
    let cellOptions = ["Logout"]
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellOptions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("moreTableCellView", forIndexPath: indexPath) as! MoreTableCellView
        
        cell.moreCellLabel!.text = cellOptions[indexPath.row];
        
        return cell;
    }
    
}
