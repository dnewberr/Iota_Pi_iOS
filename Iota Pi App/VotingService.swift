//
//  VotingService.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/17/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation
import Firebase


public protocol VotingServiceDelegate: class {
    func updateUI(topic: VotingTopic)
}

public class VotingService {
    var currentHirlyTopic: VotingTopic?
    var currentVoteTopic: VotingTopic?
    weak var votingServiceDelegate: VotingServiceDelegate?
    
    init() {}
    
    func fetchHirlyTopic() {
        let ref = FIRDatabase.database().reference().child("Voting").child("HIRLy")
        
        ref.observeSingleEvent(of: .value, with:{ (snapshot) -> Void in
            for item in snapshot.children {
                print("HERE!!")
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                let topic = VotingTopic(dict: dict, expiration: key)
                
                if (!topic.archived) {
                    self.votingServiceDelegate?.updateUI(topic: topic)
                }
            }
        })
        
    }
    
    func fetchCurrentVote() {
        let ref = FIRDatabase.database().reference().child("Voting").child("CurrentVote")
        
        ref.observeSingleEvent(of: .value, with:{ (snapshot) -> Void in
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                let topic = VotingTopic(dict: dict, expiration: key)
                
                if (!topic.archived) {
                    self.votingServiceDelegate?.updateUI(topic: topic)
                }
            }
        })
    }
    
    func validateSessionCode() {
        
    }
    
    func incrementCurrentVote(voteId: String, voteToIncrement: String) {
        
    }
    
    func submitHirlyNom(userId: String, reason: String) {
        
    }

}
