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
    var nomineeChoices = Array(RosterManager.sharedInstance.brothersMap.values)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Hello!! ", RosterManager.sharedInstance)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // print("COUNT:",  String(nomineeChoices.count))
        return nomineeChoices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nomineeCell", for: indexPath) as! NomineeTableViewCell
        
        cell.nameLabel.text = nomineeChoices[indexPath.row].firstname + " " + nomineeChoices[indexPath.row].lastname
        
        return cell
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
