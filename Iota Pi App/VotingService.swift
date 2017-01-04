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
    func denyVote()
}

public class VotingService {
    weak var votingServiceDelegate: VotingServiceDelegate?
    let baseRef = FIRDatabase.database().reference().child("Voting")
    
    init() {}
    
    func fetchHirlyTopic() {
        fetchVotingTopic(ref: baseRef.child("HIRLy"))
    }
    
    func fetchCurrentVote() {
        fetchVotingTopic(ref: baseRef.child("CurrentVote"))
    }
    
    func fetchVotingTopic(ref: FIRDatabaseReference) {
        ref.observeSingleEvent(of: .value, with:{ (snapshot) -> Void in
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
                    self.votingServiceDelegate?.denyVote()
                } else {
                    self.votingServiceDelegate?.updateUI(topic: topic)
                }
            } else {
                self.votingServiceDelegate?.noCurrentVote()
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
                    self.votingServiceDelegate?.denyVote()
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
                    self.votingServiceDelegate?.denyVote()
                }
            }
        )
    }
    
    func addNomReason(ref: FIRDatabaseReference, reason: String, nomBroId: String) {
        ref.child(nomBroId).child("reasons").child(RosterManager.sharedInstance.currentUserId).setValue(reason)
        ref.child("brosVoted").setValue([RosterManager.sharedInstance.currentUserId : true])
    }
    
    func pushCurrentVote(title: String, description: String) {
        let topic = VotingTopic(summary: title, description: description, isSessionCodeRequired: true)
        let ref = baseRef.child("CurrentVote").child(topic.getId())
        
        ref.setValue(topic.toFirebaseObject())
    }
    
    func pushHirlyNom(title: String, description: String) {
        let topic = VotingTopic(summary: title, description: description, isSessionCodeRequired: false)
        print(String(format: "INPUT: %s %s", title, description))
        let ref = baseRef.child("HIRLy").child(topic.getId())
        print(String(format: "TOPIC: %s %s", topic.summary, topic.description))
        print(topic.toFirebaseObject())
        ref.setValue(topic.toFirebaseObject())
    }
}
