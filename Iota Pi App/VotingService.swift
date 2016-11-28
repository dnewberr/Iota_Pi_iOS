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
    func confirmVote()
    func noCurrentVote()
}

public class VotingService {
    weak var votingServiceDelegate: VotingServiceDelegate?
    
    init() {}
    
    func fetchHirlyTopic() {
        let ref = FIRDatabase.database().reference().child("Voting").child("HIRLy")
        
        ref.observeSingleEvent(of: .value, with:{ (snapshot) -> Void in
            var currentHirlyTopic: VotingTopic?
            
            for item in snapshot.children {
                print("HERE!!")
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                let topic = VotingTopic(dict: dict, expiration: key)
                
                if (!topic.archived) {
                    currentHirlyTopic = topic
                    break
                    //self.votingServiceDelegate?.updateUI(topic: topic)
                }
            }
            
            if let topic = currentHirlyTopic {
                self.votingServiceDelegate?.updateUI(topic: topic)
            } else {
                self.votingServiceDelegate?.noCurrentVote()
            }
            
        })
        
    }
    
    func fetchCurrentVote() {
        let ref = FIRDatabase.database().reference().child("Voting").child("CurrentVote")
        
        ref.observeSingleEvent(of: .value, with:{ (snapshot) -> Void in
            var currentTopic: VotingTopic?
            
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                let topic = VotingTopic(dict: dict, expiration: key)
                
                if (!topic.archived) {
                    currentTopic = topic
                    //self.votingServiceDelegate?.updateUI(topic: topic)
                }
            }
            
            if let topic = currentTopic {
                self.votingServiceDelegate?.updateUI(topic: topic)
            } else {
                self.votingServiceDelegate?.noCurrentVote()
            }
        })
    }
    
    func submitCurrentVote(topic: VotingTopic, vote: String) {
        let ref = FIRDatabase.database().reference().child("Voting").child("CurrentVote").child(String(format:"%.0f", topic.id)).child(vote + "Count")
        
        ref.runTransactionBlock({(currentData: FIRMutableData!) in
            //value of the counter before an update
            var value = currentData.value as? Int
            
            if value == nil {
                value = 0
            }
                        currentData.value = value! + 1
            return FIRTransactionResult.success(withValue: currentData)
            }, andCompletionBlock: {
                error, commited, snap in
                
                if commited {
                    //let voteCounter = snap?.value as! Int
                    //call success callback function if you want
                    //successBlock(voteCounter)
                    print("SUCCESS")
                    self.votingServiceDelegate?.confirmVote()
                } else {
                    //call error callback function if you want
                    //errorBlock()
                    print("ERROR 2")
                }
        })
    }
    
    func submitHirlyNom(userId: String, reason: String) {
        
    }

}
