//
//  RosterDetailViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/18/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit

class RosterDetailTableViewController: UITableViewController {
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var graduationLabel: UILabel!
    var currentBrotherId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let currentBrother = RosterManager.sharedInstance.brothersMap[self.currentBrotherId]!
        
        if let nickname = currentBrother.nickname {
            self.nicknameLabel.text = nickname
        } else {
            self.nicknameLabel.text = "N/A"
        }
        
        self.phoneLabel.text = currentBrother.phoneNumber
        self.classLabel.text = currentBrother.educationClass
        self.emailLabel.text = currentBrother.email
        self.addressLabel.text = currentBrother.sloAddress
        self.birthdayLabel.text = currentBrother.birthday
        self.sectionLabel.text = currentBrother.section
        self.majorLabel.text = currentBrother.major
        self.graduationLabel.text = currentBrother.expectedGrad
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

class RosterDetailViewController: UIViewController {
    var currentBrotherId: String!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let currentBrother = RosterManager.sharedInstance.brothersMap[self.currentBrotherId]!
        self.numberLabel.text = String(currentBrother.rosterNumber)
        self.statusLabel.text = currentBrother.status.rawValue
        self.title = currentBrother.firstname + " " + currentBrother.lastname
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rosterDetaiListSegue" {
            let destination = segue.destination as! RosterDetailTableViewController
            destination.currentBrotherId = self.currentBrotherId
            
        }
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
