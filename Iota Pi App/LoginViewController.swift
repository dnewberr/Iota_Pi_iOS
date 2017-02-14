//
//  LoginViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 10/27/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, LoginServiceDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    let loginService = LoginService()

    @IBAction func attemptLogin(_ sender: AnyObject) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            self.loginService.attemptLogin(email: email, password: password)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loginService.loginServiceDelegate = self
        self.loginService.checkIfLoggedIn()
        
        self.errorMessageLabel.alpha = 0;

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showErrorMessage(message: String) {
        let animationDuration = 0.25
        self.errorMessageLabel.text = message
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.errorMessageLabel.alpha = 1
        }) { (Bool) -> Void in
            UIView.animate(withDuration: animationDuration, delay: 1.5, options: .curveEaseInOut, animations: { () -> Void in
                self.errorMessageLabel.alpha = 0
                },
                           completion: nil)
        }
    }
    
    func successfullyLoginLogoutUser() {
        self.performSegue(withIdentifier: "successfulLoginSegue", sender: self)
    }
}
