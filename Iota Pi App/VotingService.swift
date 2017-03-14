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
    func showMessage(message: String, title: String, isError: Bool)
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
        
        ref.observe(.value, with:{ (snapshot) -> Void in
            var archivedTopics = [VotingTopic]()
            
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let key = Double(child.key)!
                let dict = child.value as! NSDictionary
                let topic = VotingTopic(dict: dict, expiration: key)
                
                if topic.isArchived {
                    if Utilities.isOlderThanOneYear(date: topic.expirationDate) {
                        self.deleteVote(id: topic.getId(), topics: [], isHirly: isHirly, isShown: false)
                    } else {
                        archivedTopics.append(topic)
                    
                        if !topic.hasWinners() && isHirly {
                            self.calculateHirlyWinners(voteId: topic.getId())
                        }
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
                
                if !topic.isArchived {
                    VotingService.LOGGER.info("[Fetch Voting Topic] \(topic.toFirebaseObject())")
                    currentTopic = topic
                } else if !topic.hasWinners() && isHirly  {
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
    
    public func pushVotingTopic(summary: String, description: String, isHirly: Bool) {
        let newTopic = VotingTopic(summary: summary, description: description, isHirly: isHirly)
        let refString = isHirly ? "HIRLy" : "CurrentVote"
        VotingService.LOGGER.info("[Push Voting Topic] Pushing \(refString) with id = [\(newTopic.getId())]")
        
        baseRef.child(refString).child(newTopic.getId()).setValue(newTopic.toFirebaseObject(), withCompletionBlock: { (error, ref) in
            if let error = error {
                VotingService.LOGGER.error("[Push Voting Topic] \(error.localizedDescription)")
                self.votingServiceDelegate?.showMessage(message: "There was an error while trying to create a new vote.", title: "Create Vote", isError: true)
            } else {
                VotingService.LOGGER.info("[Push Voting Topic] Successfully pushed \(refString) with id = [\(newTopic.getId())]")
                self.votingServiceDelegate?.showMessage(message: "Successfully created a new vote!", title: "Create Vote", isError: false)
            }
        })
    }
    
    func submitCurrentVote(topic: VotingTopic, vote: String) {
        VotingService.LOGGER.info("[Submit Vote] Marking user current user as having voted for vote with ID \(topic.getId()).")
        
        FIRDatabase.database().reference().child("Brothers").child(RosterManager.sharedInstance.currentUserId)
            .child("lastVoteId").setValue(topic.getId(), withCompletionBlock: { (error, ref) in
            if let error = error {
                VotingService.LOGGER.error("[Submit Vote] \(error.localizedDescription)")
                self.votingServiceDelegate?.denyVote(isHirly: false, topic: nil)
            } else {
                VotingService.LOGGER.info("[Submit Vote] Submiting current vote with ID: " + topic.getId())
                let ref = self.baseRef.child("CurrentVote").child(topic.getId())
                
                ref.runTransactionBlock({(currentData: FIRMutableData!) in
                    var value =  currentData.childData(byAppendingPath: vote + "Count").value as? Int
                    
                    if value == nil {
                        value = 0
                    }
                    
                    currentData.childData(byAppendingPath: vote + "Count").value = value! + 1
                    
                    return FIRTransactionResult.success(withValue: currentData)
                }, andCompletionBlock: {error, commited, snap in
                    if commited {
                        VotingService.LOGGER.info("[Submit Vote] Successfully submitted current vote with ID: " + topic.getId())
                        self.votingServiceDelegate?.confirmVote()
                    } else {
                        if let error = error {
                            VotingService.LOGGER.error("[Submit Vote] \(error.localizedDescription)")
                        } else {
                            VotingService.LOGGER.error("[Submit Vote] Could not submit \"" + vote + "\" vote with ID " + topic.getId())
                        }
                        
                        self.votingServiceDelegate?.denyVote(isHirly: false, topic: nil)
                    }
                })
            }
        })
    }
    
    func submitHirlyNom(topic: VotingTopic, nomBroId: String, reason: String) {
        VotingService.LOGGER.info("[Submit Vote] Setting voted ID \(topic.getId()) for current user")
        
        // saving prev last voted hirly ID  - setting current to this id to prevent users from accidentally submitting twice
        let oldHirly = RosterManager.sharedInstance.brothersMap[RosterManager.sharedInstance.currentUserId]!.lastHirlyId
        
        if oldHirly != topic.getId() {
            RosterManager.sharedInstance.brothersMap[RosterManager.sharedInstance.currentUserId]!.lastHirlyId = topic.getId()
            FIRDatabase.database().reference().child("Brothers").child(RosterManager.sharedInstance.currentUserId).child("lastHirlyId").setValue(topic.getId(), withCompletionBlock: { (error, ref) in
                if let error = error {
                    VotingService.LOGGER.error("[Submit Vote] \(error.localizedDescription)")
                    // revert to old hirly id
                    RosterManager.sharedInstance.brothersMap[RosterManager.sharedInstance.currentUserId]!.lastHirlyId = oldHirly
                    self.votingServiceDelegate?.denyVote(isHirly: true, topic: topic)
                } else {
                    RosterManager.sharedInstance.brothersMap[RosterManager.sharedInstance.currentUserId]!.lastHirlyId = topic.getId()
                    VotingService.LOGGER.info("[Submit Vote] Summiting HIRLy vote with ID: " + topic.getId())
                    
                    self.baseRef.child("HIRLy").child(topic.getId()).child("noms").child(nomBroId).runTransactionBlock({(currentData: FIRMutableData!) in
                        var reasons =  currentData.childData(byAppendingPath: "reasons").value as? NSMutableArray
                        var numVotes =  currentData.childData(byAppendingPath: "numVotes").value as? Int
                    
                        if reasons == nil {
                            reasons = NSMutableArray()
                        }
                    
                        if numVotes == nil {
                            numVotes = 0
                        }
                    
                        reasons!.add(reason)
                        currentData.childData(byAppendingPath: "reasons").value = reasons!.copy() as! NSArray
                        currentData.childData(byAppendingPath: "numVotes").value = numVotes! + 1
                    
                        return FIRTransactionResult.success(withValue: currentData)
                    }, andCompletionBlock: {error, commited, snap in
                        if commited {
                            VotingService.LOGGER.info("[Submit Vote] User with ID \(nomBroId) was nominated for HIRLy vote with ID " + topic.getId())
                            self.votingServiceDelegate?.confirmVote()
                        } else {
                            if let error = error {
                                VotingService.LOGGER.error("[Submit Vote] \(error.localizedDescription)")
                            } else {
                                VotingService.LOGGER.error("[Submit Vote] Failed reason to brother with uid \(nomBroId) for vote \(topic.getId())")
                            }
                            // revert to old hirly id
                            RosterManager.sharedInstance.brothersMap[RosterManager.sharedInstance.currentUserId]!.lastHirlyId = oldHirly
                            // not doing call back because it can be done in it's own time - if we've gotten this far down the chain, it can be assumed that this won't fail due to new reasons
                            FIRDatabase.database().reference().child("Brothers").child(RosterManager.sharedInstance.currentUserId).child("lastHirlyId").setValue(oldHirly)
                            self.votingServiceDelegate?.denyVote(isHirly: true, topic: topic)
                    }
                })
            }
        })
        }
    }
    func calculateHirlyWinners(voteId: String) {
        VotingService.LOGGER.info("[Calculate Winner] Figuring out HIRLy winner for vote \(voteId).")
        var hirlyWinners = [String : [String]]()
        var highestVotes = -1
        
        baseRef.child("HIRLy").child(voteId).child("noms").observeSingleEvent(of: .value, with: { (snapshot) -> Void in            for nomination in snapshot.children {
                let nominationData = nomination as! FIRDataSnapshot
                let uid = nominationData.key
                let dict = nominationData.value as! NSDictionary
            
            
                if let numVotes = dict.value(forKey: "numVotes") as? Int, let reasons = dict.value(forKey: "reasons") as? [String] {
                    if numVotes > highestVotes {
                        hirlyWinners.removeAll()
                        hirlyWinners[uid] = reasons
                        highestVotes = numVotes
                    } else if numVotes == highestVotes {
                        hirlyWinners[uid] = reasons
                    }
                }
            }
            
            
            VotingService.LOGGER.info("[Calculate Winner] Calculated hirly winners: \(hirlyWinners).")
            self.updateWinner(voteId: voteId, winners: hirlyWinners)
        })
    }
    
    func updateWinner(voteId: String, winners: [String : [String]]) {
        VotingService.LOGGER.info("[Calculate Winner] Pushing winner(s) with uid(s) \(Array(winners.keys)) to vote \(voteId).")
        
        baseRef.child("HIRLy").child(voteId).child("winners").setValue(winners, withCompletionBlock: { (error, ref) in
            if let error = error {
                VotingService.LOGGER.error("[Calculate Winner] Error while setting winners: \(error)")
            } else {
                for (uid, _) in winners {
                    FIRDatabase.database().reference().child("Brothers").child(uid).child("hasWonHirly").setValue(true, withCompletionBlock: { (error, ref) in
                        if let error = error {
                            VotingService.LOGGER.error("[Calculate Winner]\(uid): \(error)")
                        } else {
                            VotingService.LOGGER.info("[Calculate Winner] Successfully marked brother with uid \(uid) as having won HIRLy.")
                        }
                    })
                }
            }
        })
    }
    
    public func deleteVote(id: String, topics: [VotingTopic], isHirly: Bool, isShown: Bool) {
        VotingService.LOGGER.info("[Delete Vote] Removing vote with ID \(id)")
        let voteType = isHirly ? "HIRLy" : "CurrentVote"
        baseRef.child(voteType).child(id).removeValue(completionBlock: { (error, ref) in
            if let error = error {
                VotingService.LOGGER.error("[Delete Vote] " + error.localizedDescription)
                self.votingServiceDelegate?.showMessage(message: "An error occurred while trying to delete the Vote.", title: "Delete Vote", isError: true)
            } else {
                if !topics.isEmpty {
                    self.votingServiceDelegate?.sendArchivedTopics(topics: topics.filter({$0.getId() != id}))
                }
                
                if isShown {
                    self.votingServiceDelegate?.showMessage(message: "Vote was deleted successfully.", title: "Delete Vote", isError: false)
                }
            }
        })
    }
    
    func archive(id: String, isHirly: Bool, isAuto: Bool) {
        VotingService.LOGGER.info("[Archive Vote] Archiving vote with ID \(id)")
        let voteType = isHirly ? "HIRLy" : "CurrentVote"
        baseRef.child(voteType).child(id).child("isArchived").setValue(true, withCompletionBlock: { (error, ref) in
            if let error = error {
                VotingService.LOGGER.error("[Archive Vote] " + error.localizedDescription)
                self.votingServiceDelegate?.showMessage(message: "An error occurred while trying to archive the vote.", title: "Archive Vote", isError: true)
            } else {
                if !isAuto {
                    self.votingServiceDelegate?.showMessage(message: "Vote has been closed. You can view the results in the archives.", title: "Archive Vote", isError: false)
                }
            }
        })
    }
}
