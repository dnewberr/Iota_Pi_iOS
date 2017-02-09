//
//  VotingService.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/17/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation
import Firebase
import Log

public protocol VotingServiceDelegate: class {
    func updateUI(topic: VotingTopic)
    func confirmVote()
    func noCurrentVote(isHirly: Bool)
    func denyVote(isHirly: Bool)
}

public class VotingService {
    public static let LOGGER = Logger()
    weak var votingServiceDelegate: VotingServiceDelegate?
    let baseRef = FIRDatabase.database().reference().child("Voting")
    
    init() {}
    
    func fetchHirlyTopic() {
        VotingService.LOGGER.trace("[Fetch Voting Topic] Retrieving HIRLy")
        fetchVotingTopic(ref: baseRef.child("HIRLy"), isHirly: true)
    }
    
    func fetchCurrentVote() {
        VotingService.LOGGER.trace("[Fetch Voting Topic] Retrieving Current Vote")
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
                    VotingService.LOGGER.info("[Fetch Voting Topic] \(topic.toFirebaseObject())")
                    currentTopic = topic
                }
            }
            
            if let topic = currentTopic {
                if topic.broHasVoted {
                    VotingService.LOGGER.info("[Fetch Voting Topic] User with UID \(RosterManager.sharedInstance.currentUserId) has already voted.")
                    self.votingServiceDelegate?.denyVote(isHirly: isHirly)
                } else {
                    VotingService.LOGGER.info("[Fetch Voting Topic] Successfully retrieved voting topic.")
                    self.votingServiceDelegate?.updateUI(topic: topic)
                }
            } else {
                VotingService.LOGGER.info("[Fetch Voting Topic] There was no active voting topic found.")
                self.votingServiceDelegate?.noCurrentVote(isHirly: isHirly)
            }
        })
    }
    
    func submitCurrentVote(topic: VotingTopic, vote: String) {
        VotingService.LOGGER.info("[Submit Vote] Submiting current vote with ID: " + topic.getId())
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
                    VotingService.LOGGER.info("[Submit Vote] Vote with ID " + topic.getId() + " increased the \"" + vote + "\" vote by one.")
                    self.votingServiceDelegate?.confirmVote()
                } else {
                    VotingService.LOGGER.error("[Submit Vote] Could not submit \"" + vote + "\" vote with ID " + topic.getId())
                    self.votingServiceDelegate?.denyVote(isHirly: false)
                }
            }
        )
    }
    
    func markBroAsVoted(ref: FIRDatabaseReference) {
        VotingService.LOGGER.info("[Submit Vote] Marking user with UID \(RosterManager.sharedInstance.currentUserId) as having voted.")
        ref.child("brosVoted").setValue([RosterManager.sharedInstance.currentUserId : true])
    }
    
    func submitHirlyNom(topic: VotingTopic, nomBroId: String, reason: String) {
        VotingService.LOGGER.info("[Submit Vote] Summiting HIRLy vote with ID: " + topic.getId())
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
                    VotingService.LOGGER.info("[Submit Vote] User with ID \(nomBroId) was nominated for HIRLy vote with ID " + topic.getId())
                    self.votingServiceDelegate?.confirmVote()
                } else {
                    VotingService.LOGGER.info("[Submit Vote] Could not nominate user with ID \(nomBroId) for HIRLy vote with ID " + topic.getId())
                    self.votingServiceDelegate?.denyVote(isHirly: true)
                }
            }
        )
    }
    
    func addNomReason(ref: FIRDatabaseReference, reason: String, nomBroId: String) {
        VotingService.LOGGER.info("[Submit Vote] Marking user with UID \(RosterManager.sharedInstance.currentUserId) as having voted.")
        ref.child(nomBroId).child("reasons").child(RosterManager.sharedInstance.currentUserId).setValue(reason)
        ref.child("brosVoted").setValue([RosterManager.sharedInstance.currentUserId : true])
    }
}
