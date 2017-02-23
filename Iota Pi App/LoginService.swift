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
        if (email.trim().isEmpty || password.isEmpty) {
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
            
            if let admin = snapshot.childSnapshot(forPath: "admin").value as? String {
                switch admin {
                    case "President" : RosterManager.sharedInstance.currentUserAdmin = AdminPrivileges.President
                    case "VicePresident" : RosterManager.sharedInstance.currentUserAdmin = AdminPrivileges.VicePresident
                    case "RecSec" : RosterManager.sharedInstance.currentUserAdmin = AdminPrivileges.RecSec
                    case "Parliamentarian" : RosterManager.sharedInstance.currentUserAdmin = AdminPrivileges.Parliamentarian
                    case "BrotherhoodCommitteeChair" : RosterManager.sharedInstance.currentUserAdmin = AdminPrivileges.BrotherhoodCommitteeChair
                    case "OtherCommitteeChair" : RosterManager.sharedInstance.currentUserAdmin  = AdminPrivileges.OtherCommitteeChair
                    case "Webmaster" : RosterManager.sharedInstance.currentUserAdmin = AdminPrivileges.Webmaster
                    default : RosterManager.sharedInstance.currentUserAdmin = AdminPrivileges.None
                }
                
            } else {
                RosterManager.sharedInstance.currentUserAdmin = AdminPrivileges.None
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
                    self.loginServiceDelegate?.showErrorMessage(message: "Your account has not yet been validated.")
                }
            } else {
                LoginService.LOGGER.info("[Check Login] Verification value not set.")
                self.loginServiceDelegate?.showErrorMessage(message: "Your account has not yet been validated.")
            }
        })
    }
    
    func deleteUser() {
        LoginService.LOGGER.info("[Delete User] UID: " + RosterManager.sharedInstance.currentUserId)
        FIRDatabase.database().reference().child("Brothers").child(RosterManager.sharedInstance.currentUserId).setValue(nil)
        
        FIRAuth.auth()?.currentUser?.delete(completion: { (err) in
            if let error = err {
                LoginService.LOGGER.info("[Delete User] Error while deleting user with UID [\(RosterManager.sharedInstance.currentUserId)]: \(error.localizedDescription)")
                self.loginServiceDelegate?.showErrorMessage(message: "There was an error logging you in. Contact exec council for details.")
            } else {
                self.loginServiceDelegate?.showErrorMessage(message: "Your account has been deleted.")
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
        let email = (userInfo["firstname"] as! String) + "." + (userInfo["lastname"] as! String) + "@iotapi.com"
        LoginService.LOGGER.trace("[Create User] Creating a new user with temp password \"test123\" and email \"\(email)\"")
        
        FIRAuth.auth()?.createUser(withEmail: email, password: "test123", completion: {(user: FIRUser?, error) in
            if error == nil {
                LoginService.LOGGER.info("[Create User] Registration successful for new UID: " + user!.uid)
                FIRDatabase.database().reference().child("Brothers").child(user!.uid).setValue(userInfo)
                self.loginServiceDelegate?.successfullyLoginLogoutUser()
            } else {
                LoginService.LOGGER.error("[Create User] " + (error?.localizedDescription)!)
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
