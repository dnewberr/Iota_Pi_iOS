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
    public static let LOGGER = Logger()
    
    weak var loginServiceDelegate: LoginServiceDelegate?
    
    init() {}
    
    func attemptLogin(email: String, password: String) {
        LoginService.LOGGER.trace("[Sign In] Attempting sign in user with email: " + email)
        if (email.isEmpty || password.isEmpty) {
            LoginService.LOGGER.warning("[Sign In] No email or password entered.")
            self.loginServiceDelegate?.showErrorMessage(message: "Please enter an email and password.")
        } else {
            FIRAuth.auth()!.signIn(withEmail: email, password: password) { user, error in
                if error == nil {
                    LoginService.LOGGER.info("[Sign In] UID: " + (user?.uid)!)
                    RosterManager.sharedInstance.currentUserId = user?.uid
                    self.loginServiceDelegate?.successfullyLoginLogoutUser()
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
                LoginService.LOGGER.info("[Sign In] User already signed in with UID: " + (user?.uid)!)
                RosterManager.sharedInstance.currentUserId = user?.uid
                self.loginServiceDelegate?.successfullyLoginLogoutUser()
            } else {
                LoginService.LOGGER.trace("[Sign In] No user authenticated.")
            }
        }
    }
    
    func logoutCurrentUser() {
        LoginService.LOGGER.info("[Log Out] UID: " + RosterManager.sharedInstance.currentUserId)
        
        do {
            try FIRAuth.auth()!.signOut()
            LoginService.LOGGER.info("[Log Out] Successfully logged out current user.")
            self.loginServiceDelegate?.successfullyLoginLogoutUser()
        } catch let error {
            LoginService.LOGGER.error("[Log Out] " + error.localizedDescription)
            self.loginServiceDelegate?.showErrorMessage(message: "There was an error when attempting to log out of the application.")
        }
    }
    
    func createNewUser(userInfo: [AnyHashable:Any]) {
        LoginService.LOGGER.trace("[Create User] Creating a new user with temp password \"test123\"")
        let email = (userInfo["firstname"] as! String) + "." + (userInfo["lastname"] as! String) + "@iotapi.com"
        
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
}
