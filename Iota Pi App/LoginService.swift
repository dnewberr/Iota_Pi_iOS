//
//  LoginService.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/17/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import Foundation
import Firebase

public protocol LoginServiceDelegate: class {
    func showErrorMessage(message: String)
    func successfullyLoginLogoutUser()
}

public class LoginService {
    weak var loginServiceDelegate: LoginServiceDelegate?
    
    init() {}
    
    func attemptLogin(email: String, password: String) {
        if (email.isEmpty || password.isEmpty) {
            // self.errorMessageAnimation(text: "Fill out email and pw")
            self.loginServiceDelegate?.showErrorMessage(message: "Please enter an email and password.")
        } else {
            FIRAuth.auth()!.signIn(withEmail: email, password: password) { user, error in
                if error == nil {
                    RosterManager.sharedInstance.currentUserId = user?.uid
                    
                   // self.performSegue(withIdentifier: "successfulLoginSegue", sender: sender)
                    self.loginServiceDelegate?.successfullyLoginLogoutUser()
                } else {
                    self.loginServiceDelegate?.showErrorMessage(message: "Incorrect email and password combination.")
                }
            }
        }
    }
    
    func checkIfLoggedIn() {
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                RosterManager.sharedInstance.currentUserId = user?.uid
                //self.performSegue(withIdentifier: "successfulLoginSegue", sender: self)
                self.loginServiceDelegate?.successfullyLoginLogoutUser()
            }
        }
    }
    
    func logoutCurrentUser() {
        try! FIRAuth.auth()!.signOut()
        self.loginServiceDelegate?.successfullyLoginLogoutUser()
    }
    
    func createNewUser(userInfo: [AnyHashable:Any]) {
        let email = (userInfo["firstname"] as! String) + "." + (userInfo["lastname"] as! String) + "@iotapi.com"
        FIRAuth.auth()?.createUser(withEmail: email, password: "test123", completion: {(user: FIRUser?, error) in
            if error == nil {
                //registration successful
                FIRDatabase.database().reference().child("Brothers").child(user!.uid).setValue(userInfo)
                print("UID:::: " + user!.uid)
                self.loginServiceDelegate?.successfullyLoginLogoutUser()
            } else{
                //registration failure
                print("NOOOOOOOOO nikroiaknfulewiakh cdisuljbvhjs")
            }
        })
    }
}
