//
//  CurrentVoteViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/17/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import Firebase

class CurrentVoteViewController: UIViewController {
    @IBOutlet weak var sessionCodeText: UITextField!
    @IBAction func yesVote(_ sender: AnyObject) {
    }
    @IBAction func abstainVote(_ sender: AnyObject) {
    }
    @IBAction func noVote(_ sender: AnyObject) {
    }
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    var currentTopic: VotingTopic!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let ref = FIRDatabase.database().reference().child("Voting").child("CurrentVote")
        
        ref.observeSingleEvent(of: .value, with:{ (snapshot) -> Void in
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                let topic = VotingTopic(dict: dict, expiration: key)
                
                if (!topic.archived) {
                    self.currentTopic = topic
                }
            }
            
            self.summaryLabel.text = self.currentTopic.summary
            self.descriptionLabel.text = self.currentTopic.description
        })
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
