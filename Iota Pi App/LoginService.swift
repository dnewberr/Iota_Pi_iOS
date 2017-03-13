//
//  LoginService.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/17/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation
import Firebase
import Log

public protocol LoginServiceDelegate: class {
    func showErrorMessage(message: String)
    func successfullyLoginLogoutUser()
}

public class LoginService {
    public static let LOGGER = Logger(formatter: Formatter("🚹 [%@] %@ %@: %@", .date("dd/MM/yy HH:mm"), .location, .level, .message), theme: nil, minLevel: .trace)
    weak var loginServiceDelegate: LoginServiceDelegate?
    
    init() {}
    
    func attemptLogin(email: String, password: String) {
        LoginService.LOGGER.trace("[Sign In] Attempting sign in user with email: " + email)
        if email.trim().isEmpty || password.isEmpty {
            LoginService.LOGGER.warning("[Sign In] No email or password entered.")
            self.loginServiceDelegate?.showErrorMessage(message: "Please enter an email and password.")
        } else {
            let fullEmail = email.contains("@") ? email : email + "@iotapi.com"
            FIRAuth.auth()!.signIn(withEmail: fullEmail, password: password) { user, error in
                if error == nil {
                    RosterManager.sharedInstance.currentUserId = user!.uid
                    self.checkIfCanLogIn(uid: user!.uid)
                } else {
                    LoginService.LOGGER.warning("[Sign In] " + error!.localizedDescription)
                    self.loginServiceDelegate?.showErrorMessage(message: "Incorrect email and password combination.")
                }
            }
        }
    }
    
    func checkIfLoggedIn() {
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                LoginService.LOGGER.info("[Sign In] User with UID: [" + user!.uid + "] exists.")
                RosterManager.sharedInstance.currentUserId = user!.uid
                self.checkIfCanLogIn(uid: user!.uid)
            } else {
                LoginService.LOGGER.trace("[Sign In] No user authenticated.")
                self.loginServiceDelegate?.showErrorMessage(message: "Please log in.")
            }
        }
    }
    
    func checkIfCanLogIn(uid: String) {
        FIRDatabase.database().reference().child("Brothers").child(uid).observeSingleEvent(of: .value, with: {(snapshot) -> Void in
            // Only Active and Associate members can participate fully in matters involving voting and introducing business
            // https://www.kkytbs.org/forms/KKPsiGuidetoMembership.pdf page 84
            // if a member is not of Active status, their privileges are automatically none, and they cannot vote
            RosterManager.sharedInstance.currentUserAdmin = .NoVoting
            if let status = snapshot.childSnapshot(forPath: "status").value as? String {
                if status == "Active" || status  == "Associate" {
                    if let admin = snapshot.childSnapshot(forPath: "admin").value as? String {
                        switch admin {
                            case "President" : RosterManager.sharedInstance.currentUserAdmin = .President
                            case "VicePresident" : RosterManager.sharedInstance.currentUserAdmin = .VicePresident
                            case "RecordingSecretary" : RosterManager.sharedInstance.currentUserAdmin = .RecSec
                            case "Parliamentarian" : RosterManager.sharedInstance.currentUserAdmin = .Parliamentarian
                            case "BrotherhoodCommitteeChair" : RosterManager.sharedInstance.currentUserAdmin = .BrotherhoodCommitteeChair
                            case "OtherCommitteeChair" : RosterManager.sharedInstance.currentUserAdmin  = .OtherCommitteeChair
                            case "Webmaster" : RosterManager.sharedInstance.currentUserAdmin = .Webmaster
                            default : RosterManager.sharedInstance.currentUserAdmin = .None
                        }
                    }
                }
            }
            
            if let isDeleted = snapshot.childSnapshot(forPath: "isDeleted").value as? Bool {
                if isDeleted {
                    LoginService.LOGGER.info("[Check Login] User has been marked as deleted.")
                    self.deleteUser()
                }
            } else if let isValidated = snapshot.childSnapshot(forPath: "isValidated").value as? Bool {
                if isValidated {
                    if !RosterManager.sharedInstance.currentUserAlreadyLoggedIn {
                        LoginService.LOGGER.info("[Check Login] User has been verified.")
                        RosterManager.sharedInstance.currentUserAlreadyLoggedIn = true
                        self.loginServiceDelegate?.successfullyLoginLogoutUser()
                    } else {
                        LoginService.LOGGER.info("[Check Login] User has been verified and has already been logged in.")
                    }
                } else {
                    LoginService.LOGGER.info("[Check Login] User not verified.")
                    self.loginServiceDelegate?.showErrorMessage(message: "Your account is not validated.")
                }
            } else {
                LoginService.LOGGER.info("[Check Login] Verification value not set.")
                self.loginServiceDelegate?.showErrorMessage(message: "Your account is not validated.")
            }
        })
    }
    
    func deleteUser() {
        let uid = RosterManager.sharedInstance.currentUserId!
        LoginService.LOGGER.info("[Delete User] Deleting account with UID: " + uid)
        
        FIRAuth.auth()?.currentUser?.delete(completion: { (err) in
            if let error = err {
                LoginService.LOGGER.info("[Delete User] Error while deleting user with UID [\(uid)]: \(error.localizedDescription)")
                self.loginServiceDelegate?.showErrorMessage(message: "There was an error while logging in. Contact the webmaster for assistance.")
            } else {
                LoginService.LOGGER.info("[Delete User] Successfully deleted account: " + uid)
                LoginService.LOGGER.info("[Delete User] Removing references of UID: " + uid + " from the databse")
                FIRDatabase.database().reference().child("Brothers").child(uid).removeValue(completionBlock: { (error, ref) in
                    if let error = error {
                        LoginService.LOGGER.info("[Delete User] Error while deleting database reference of UID [\(uid)]: \(error.localizedDescription)")
                        self.loginServiceDelegate?.showErrorMessage(message: "There was an error while logging in. Contact the webmaster for assistance.")
                    } else {
                        LoginService.LOGGER.info("[Delete User] Successfully removed all references to UID: " + RosterManager.sharedInstance.currentUserId + " from the database.")
                        self.loginServiceDelegate?.showErrorMessage(message: "Your account has been deleted.")
                    }
                })
            }
        })
    }
    
    func logoutCurrentUser(isCreate: Bool) {
        LoginService.LOGGER.info("[Log Out] UID: " + RosterManager.sharedInstance.currentUserId)
        
        do {
            try FIRAuth.auth()!.signOut()
            RosterManager.sharedInstance.currentUserAlreadyLoggedIn = false
            LoginService.LOGGER.info("[Log Out] Successfully logged out current user.")
            if !isCreate {
                self.loginServiceDelegate?.successfullyLoginLogoutUser()
            }
        } catch let error {
            LoginService.LOGGER.error("[Log Out] " + error.localizedDescription)
            self.loginServiceDelegate?.showErrorMessage(message: "There was an error while attempting to log out of the application.")
        }
    }
    
    func createNewUser(userInfo: [AnyHashable:Any]) {
        let email = (userInfo["firstname"] as! String).lowercased().trim() + "." + (userInfo["lastname"] as! String).lowercased().trim() + "@iotapi.com"
        LoginService.LOGGER.trace("[Create User] Creating a new user with temp password \"test123\" and email \"\(email)\"")
        
        FIRAuth.auth()?.createUser(withEmail: email, password: "test123", completion: {(user: FIRUser?, error) in
            if let error = error {
                LoginService.LOGGER.error("[Create User] " + error.localizedDescription)
                let errCode = FIRAuthErrorCode(rawValue: error._code)!
                var message: String
                
                switch errCode {
                    case .errorCodeEmailAlreadyInUse:
                        message = "A user with this email already exists. Contact the webmaster for assistance."
                    default:
                        message = "There was a problem while creating the account. Please try again later."
                }
                
                self.loginServiceDelegate?.showErrorMessage(message: message)
            } else {
                LoginService.LOGGER.info("[Create User] Creation successful for new UID: " + user!.uid)
                FIRDatabase.database().reference().child("Brothers").child(user!.uid).setValue(userInfo, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        LoginService.LOGGER.error("[Create User] " + error.localizedDescription)
                        self.loginServiceDelegate?.showErrorMessage(message: "There was an error while creating your account. Contact the webmaster for assistance.")
                    } else {
                        LoginService.LOGGER.info("[Create User] Database initialization successful for new UID: " + user!.uid)
                        self.loginServiceDelegate?.successfullyLoginLogoutUser()
                    }
                })
            }
        })
    }
    
    func changePassword(oldPassword: String, newPassword: String) {
        LoginService.LOGGER.info("[Change Password] Changing password for UID " + RosterManager.sharedInstance.currentUserId)
        let user = FIRAuth.auth()!.currentUser!
        let credential = FIREmailPasswordAuthProvider.credential(withEmail: user.email!, password: oldPassword)
        
        user.reauthenticate(with: credential) { error in
            if let error = error {
                LoginService.LOGGER.error("[Change Password] " + error.localizedDescription)
                self.loginServiceDelegate?.showErrorMessage(message: "Please enter the correct current password.")
            } else {
                user.updatePassword(newPassword) { error in
                    if let error = error {
                        LoginService.LOGGER.error("[Change Password] " + error.localizedDescription)
                        self.loginServiceDelegate?.showErrorMessage(message: "An error occured while trying to change your password. The change was unsuccessful.")
                    } else {
                        LoginService.LOGGER.info("[Change Password] Password successfully changed.")
                        self.loginServiceDelegate?.successfullyLoginLogoutUser()
                    }
                }
            }
        }
    }
    
    func resetPassword(email: String) {
        LoginService.LOGGER.info("[Reset Password] Resetting password for user with email: " + email)
        FIRAuth.auth()!.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                LoginService.LOGGER.error("[Reset Password] " + error.localizedDescription)
                self.loginServiceDelegate?.showErrorMessage(message: "Username or email not found.")
            } else {
                LoginService.LOGGER.info("[Reset Password] Password reset email sent.")
                self.loginServiceDelegate?.showErrorMessage(message: "An email has been sent to you to reset your password.")
            }
        }
    }
}
