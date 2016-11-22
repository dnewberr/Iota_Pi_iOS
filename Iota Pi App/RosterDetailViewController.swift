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
    var currentBrother: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nickname = self.currentBrother.nickname {
            self.nicknameLabel.text = nickname
        } else {
            self.nicknameLabel.text = "N/A"
        }
        
        self.phoneLabel.text = self.currentBrother.phoneNumber
        self.classLabel.text = self.currentBrother.educationClass
        self.emailLabel.text = self.currentBrother.email
        self.addressLabel.text = self.currentBrother.sloAddress
        self.birthdayLabel.text = self.currentBrother.birthday
        self.sectionLabel.text = self.currentBrother.section
        self.majorLabel.text = self.currentBrother.major
        self.graduationLabel.text = self.currentBrother.expectedGrad
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

class RosterDetailViewController: UIViewController {
    var currentBrother: User!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.numberLabel.text = String(self.currentBrother.rosterNumber) + " | "
        self.statusLabel.text = self.currentBrother.status.rawValue
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rosterDetaiListSegue" {
            let destination = segue.destination as! RosterDetailTableViewController
            destination.currentBrother = self.currentBrother
            
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
