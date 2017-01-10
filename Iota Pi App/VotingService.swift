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
    func noCurrentVote(isHirly: Bool)
    func denyVote(isHirly: Bool)
}

public class VotingService {
    weak var votingServiceDelegate: VotingServiceDelegate?
    let baseRef = FIRDatabase.database().reference().child("Voting")
    
    init() {}
    
    func fetchHirlyTopic() {
        fetchVotingTopic(ref: baseRef.child("HIRLy"), isHirly: true)
    }
    
    func fetchCurrentVote() {
        fetchVotingTopic(ref: baseRef.child("CurrentVote"), isHirly: false)
    }
    
    func fetchVotingTopic(ref: FIRDatabaseReference, isHirly: Bool) {
        ref.observe(.value, with:{ (snapshot) -> Void in
            var currentTopic: VotingTopic?
            
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                let topic = VotingTopic(dict: dict, expiration: key)
                
                if (!topic.archived) {
                    currentTopic = topic
                }
            }
            
            if let topic = currentTopic {
                if topic.broHasVoted {
                    self.votingServiceDelegate?.denyVote(isHirly: isHirly)
                } else {
                    self.votingServiceDelegate?.updateUI(topic: topic)
                }
            } else {
                self.votingServiceDelegate?.noCurrentVote(isHirly: isHirly)
            }
        })
    }
    
    func submitCurrentVote(topic: VotingTopic, vote: String) {
        let ref = baseRef.child("CurrentVote").child(topic.getId())
        
        ref.runTransactionBlock({(currentData: FIRMutableData!) in
            var value =  currentData.childData(byAppendingPath: vote + "Count").value as? Int
            if value == nil {
                value = 0
            }
            
            currentData.childData(byAppendingPath: vote + "Count").value = value! + 1
        
            return FIRTransactionResult.success(withValue: currentData)
            }, andCompletionBlock: {error, commited, snap in
                if commited {
                    self.markBroAsVoted(ref: ref)
                    self.votingServiceDelegate?.confirmVote()
                } else {
                    self.votingServiceDelegate?.denyVote(isHirly: false)
                }
            }
        )
    }
    
    func markBroAsVoted(ref: FIRDatabaseReference) {
        ref.child("brosVoted").setValue([RosterManager.sharedInstance.currentUserId : true])
    }
    
    func submitHirlyNom(topic: VotingTopic, nomBroId: String, reason: String) {
        let ref = baseRef.child("HIRLy").child(topic.getId())
        
        ref.runTransactionBlock({(currentData: FIRMutableData!) in
            var value =  currentData.childData(byAppendingPath: "noms").childData(byAppendingPath: nomBroId).childData(byAppendingPath: "numNoms").value as? Int
            
            if value == nil {
                value = 0
            }
            
            currentData.childData(byAppendingPath: "noms").childData(byAppendingPath: nomBroId).childData(byAppendingPath: "numNoms").value = value! + 1
            
            return FIRTransactionResult.success(withValue: currentData)
            }, andCompletionBlock: {error, commited, snap in
                if commited {
                    self.addNomReason(ref: ref, reason: reason, nomBroId: nomBroId)
                    self.votingServiceDelegate?.confirmVote()
                } else {
                    self.votingServiceDelegate?.denyVote(isHirly: true)
                }
            }
        )
    }
    
    func addNomReason(ref: FIRDatabaseReference, reason: String, nomBroId: String) {
        ref.child(nomBroId).child("reasons").child(RosterManager.sharedInstance.currentUserId).setValue(reason)
        ref.child("brosVoted").setValue([RosterManager.sharedInstance.currentUserId : true])
    }
}
