//
//  RosterViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/17/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit

class RosterTableViewCell: UITableViewCell {
    @IBOutlet weak var rosterLabel: UILabel!
    var brother: User!
    
}

class RosterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var rosterTable: UITableView!
    
    //let roster =
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RosterManager.sharedInstance.brothersMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rosterCell", for: indexPath) as! RosterTableViewCell
        
        
        cell.brother = Array(RosterManager.sharedInstance.brothersMap.values)[indexPath.row]
        cell.rosterLabel.text = cell.brother.firstname + " " + cell.brother.lastname
        
        
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
