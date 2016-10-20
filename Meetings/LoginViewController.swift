//
//  LoginViewController.swift
//  Meetings
//
//  Created by Deborah Newberry on 10/17/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!

    @IBAction func login(sender: AnyObject) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            if (email.isEmpty || password.isEmpty) {
                self.errorMessageAnimation(ErrorMessage.EmptyLogin)
            } else {
                FIRAuth.auth()!.signInWithEmail(email, password: password) { user, error in
                    if error == nil {
                        self.performSegueWithIdentifier("successfulLoginSegue", sender: sender)
                    } else {
                        self.errorMessageAnimation((error?.description)!)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        self.errorMessageLabel.alpha = 0;
    }
    
    func errorMessageAnimation(text: String) {
        let animationDuration = 0.25
        self.errorMessageLabel.text = text
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.errorMessageLabel.alpha = 1
        }) { (Bool) -> Void in
            UIView.animateWithDuration(animationDuration, delay: 1.5, options: .CurveEaseInOut, animations: { () -> Void in
                self.errorMessageLabel.alpha = 0
            },
            completion: nil)
        }
    }
    
}