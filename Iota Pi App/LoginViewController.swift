//
//  LoginViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 10/27/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!

    @IBAction func attemptLogin(_ sender: AnyObject) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            if (email.isEmpty || password.isEmpty) {
                self.errorMessageAnimation(text: "Fill out email and pw")
            } else {
                FIRAuth.auth()!.signIn(withEmail: email, password: password) { user, error in
                    if error == nil {
                        self.performSegue(withIdentifier: "successfulLoginSegue", sender: sender)
                    } else {
                        self.errorMessageAnimation(text: "TEMP")
                    }
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.errorMessageLabel.alpha = 0;
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "successfulLoginSegue", sender: self)
            }
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))

        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func errorMessageAnimation(text: String) {
        let animationDuration = 0.25
        self.errorMessageLabel.text = text
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.errorMessageLabel.alpha = 1
        }) { (Bool) -> Void in
            UIView.animate(withDuration: animationDuration, delay: 1.5, options: .curveEaseInOut, animations: { () -> Void in
                self.errorMessageLabel.alpha = 0
                },
                           completion: nil)
        }
    }
}
