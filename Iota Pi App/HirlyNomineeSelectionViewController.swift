//
//  HirlyNomineeSelectionViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/16/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit

//nomineeCell
class NomineeTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}

class HirlyNomineeSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var nomineeTableView: UITableView!
    
    let nomineeChoices = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()

        nomineeChoices = RosterManager.sharedInstance.brothersMap.values as! [User]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
