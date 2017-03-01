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
    func denyVote(isHirly: Bool, topic: VotingTopic?)
    func sendArchivedTopics(topics: [VotingTopic])
}

public class VotingService {
    public static let LOGGER = Logger(formatter: Formatter("✅ [%@] %@ %@: %@", .date("dd/MM/yy HH:mm"), .location, .level, .message), theme: nil, minLevel: .trace)
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
    
    func fetchArchivedVotingTopics(isHirly: Bool) {
        let ref = isHirly ? baseRef.child("HIRLy") : baseRef.child("CurrentVote")
        var archivedTopics = [VotingTopic]()
        
        ref.observe(.value, with:{ (snapshot) -> Void in
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                let topic = VotingTopic(dict: dict, expiration: key)
                
                if topic.archived {
                    archivedTopics.append(topic)
                    
                    if topic.winners == "N/A" && isHirly {
                        self.calculateHirlyWinners(voteId: topic.getId())
                    }
                }
            }
            
            VotingService.LOGGER.info("[Fetch Archived Topics] Retrieved \(archivedTopics.count) archived topics for isHirly = [\(isHirly)]")
            
            self.votingServiceDelegate?.sendArchivedTopics(topics: archivedTopics)
        })
    }
    
    func fetchVotingTopic(ref: FIRDatabaseReference, isHirly: Bool) {
        ref.observe(.value, with:{ (snapshot) -> Void in
            var currentTopic: VotingTopic?
            
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                let topic = VotingTopic(dict: dict, expiration: key)
                
                if !topic.archived {
                    VotingService.LOGGER.info("[Fetch Voting Topic] \(topic.toFirebaseObject())")
                    currentTopic = topic
                } else if topic.winners == "N/A" && isHirly  {
                    self.calculateHirlyWinners(voteId: topic.getId())
                }
            }
            
            if let topic = currentTopic {
                if topic.hasCurrentBroVoted(isHirly: isHirly) {
                    VotingService.LOGGER.info("[Fetch Voting Topic] User with UID \(RosterManager.sharedInstance.currentUserId) has already voted.")
                    self.votingServiceDelegate?.denyVote(isHirly: isHirly, topic: topic)
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
                    self.markBroAsVoted(ref: ref, voteId: topic.getId())
                    VotingService.LOGGER.info("[Submit Vote] Vote with ID " + topic.getId() + " increased the \"" + vote + "\" vote by one.")
                    self.votingServiceDelegate?.confirmVote()
                } else {
                    VotingService.LOGGER.error("[Submit Vote] Could not submit \"" + vote + "\" vote with ID " + topic.getId())
                    self.votingServiceDelegate?.denyVote(isHirly: false, topic: nil)
                }
            }
        )
    }
    
    func markBroAsVoted(ref: FIRDatabaseReference, voteId: String) {
        VotingService.LOGGER.info("[Submit Vote] Marking user with UID \(RosterManager.sharedInstance.currentUserId) as having voted.")
        FIRDatabase.database().reference().child("Brothers").child(RosterManager.sharedInstance.currentUserId).child("lastVoteId").setValue(voteId)
        RosterManager.sharedInstance.brothersMap[RosterManager.sharedInstance.currentUserId]!.lastVoteId = voteId
    }
    
    func submitHirlyNom(topic: VotingTopic, nomBroId: String, reason: String) {
        VotingService.LOGGER.info("[Submit Vote] Summiting HIRLy vote with ID: " + topic.getId())
        let ref = baseRef.child("HIRLy").child(topic.getId())
        
        ref.runTransactionBlock({(currentData: FIRMutableData!) in
            var value =  currentData.childData(byAppendingPath: "noms").childData(byAppendingPath: nomBroId).value as? Int
            
            if value == nil {
                value = 0
            }
            
            currentData.childData(byAppendingPath: "noms").childData(byAppendingPath: nomBroId).value = value! + 1
            
            return FIRTransactionResult.success(withValue: currentData)
            }, andCompletionBlock: {error, commited, snap in
                if commited {
                    self.addNomReason(ref: ref, reason: reason, nomBroId: nomBroId, hirlyId: topic.getId())
                    VotingService.LOGGER.info("[Submit Vote] User with ID \(nomBroId) was nominated for HIRLy vote with ID " + topic.getId())
                    self.votingServiceDelegate?.confirmVote()
                } else {
                    VotingService.LOGGER.info("[Submit Vote] Could not nominate user with ID \(nomBroId) for HIRLy vote with ID " + topic.getId())
                    self.votingServiceDelegate?.denyVote(isHirly: true, topic: nil)
                }
            }
        )
    }
    
    func addNomReason(ref: FIRDatabaseReference, reason: String, nomBroId: String, hirlyId: String) {
        VotingService.LOGGER.info("[Submit Vote] Marking user with UID \(RosterManager.sharedInstance.currentUserId) as having voted.")
        
        ref.child(nomBroId).child(RosterManager.sharedInstance.currentUserId).setValue(reason)
        FIRDatabase.database().reference().child("Brothers").child(RosterManager.sharedInstance.currentUserId).child("lastHirlyId").setValue(hirlyId)
        RosterManager.sharedInstance.brothersMap[RosterManager.sharedInstance.currentUserId]!.lastHirlyId = hirlyId
        
        //TODO remove
//        ref.child("brosVoted").setValue([RosterManager.sharedInstance.currentUserId : true])
    }
    
    func calculateHirlyWinners(voteId: String) {
        VotingService.LOGGER.info("[Calculate Winner] Figuring out HIRLy winner for vote \(voteId).")
        var hirlyWinners = [String]()
        var maxNoms = -1
        
        baseRef.child("HIRLy").child(voteId).child("noms").observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            for contender in snapshot.children {
                let contenderData = contender as! FIRDataSnapshot
//                let dict =
                if let numVotes = contenderData.value as? Int {
                    if numVotes > maxNoms {
                        hirlyWinners.removeAll()
                        hirlyWinners.append(contenderData.key)
                        maxNoms = numVotes
                    } else if numVotes == maxNoms {
                        hirlyWinners.append(contenderData.key)
                    }
                }
            }
            
            self.updateWinner(voteId: voteId, winners: hirlyWinners)
        })
    }
    
    func updateWinner(voteId: String, winners: [String]) {
        VotingService.LOGGER.info("[Calculate Winner] Pushing winner(s) with uid(s) \(winners) to vote \(voteId).")
        baseRef.child("HIRLy").child(voteId).child("winners").setValue(winners)
        
        for uid in winners {
            FIRDatabase.database().reference().child("Brothers").child(uid).child("hasWonHirly").setValue(true)
        }
    }
}
