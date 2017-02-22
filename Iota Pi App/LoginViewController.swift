//
//  LoginViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 10/27/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, LoginServiceDelegate, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    let animationDuration = 0.25
    let loginService = LoginService()
    var blurredEffectView: UIVisualEffectView!
    var indicator: UIActivityIndicatorView!

    @IBAction func attemptLogin(_ sender: AnyObject) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            self.indicator.startAnimating()
            self.blurView()
            self.loginService.attemptLogin(email: email, password: password)
        }
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .dark)
        self.blurredEffectView = UIVisualEffectView(effect: blurEffect)
        self.blurredEffectView.frame = self.view.frame
        view.addSubview(self.blurredEffectView)
        self.blurredEffectView.alpha = 0;
        
        self.indicator = Utilities.createActivityIndicator(center: self.view.center)
        self.view.addSubview(indicator)
        
        self.loginService.loginServiceDelegate = self
        self.indicator.startAnimating()
        self.blurView()
        self.loginService.checkIfLoggedIn()
        
        self.errorMessageLabel.alpha = 0;

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // Closes keyboard when tapped outside textfields
    func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if self.emailTextField == textField {
            passwordTextField.becomeFirstResponder()
        } else if self.passwordTextField == textField {
            textField.resignFirstResponder()
            self.attemptLogin(textField)
        }
        
        return true
    }
    
    
    func showErrorMessage(message: String) {
        self.indicator.stopAnimating()
        self.blurredEffectView.alpha = 0
        self.errorMessageLabel.text = message
        
        UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
            self.errorMessageLabel.alpha = 1
        }) { (Bool) -> Void in
            UIView.animate(withDuration: self.animationDuration, delay: 1.5, options: .curveEaseInOut, animations: { () -> Void in
                self.errorMessageLabel.alpha = 0
            }, completion: nil)
        }
    }
    
    func blurView() {
        UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
            self.blurredEffectView.alpha = 1
        }) { (Bool) -> Void in
            UIView.animate(withDuration: self.animationDuration, delay: 10, options: .curveEaseInOut, animations: { () -> Void in
                self.blurredEffectView.alpha = 0
            }, completion: nil)
        }
    }
    
    func successfullyLoginLogoutUser() {
        self.indicator.stopAnimating()
        self.performSegue(withIdentifier: "successfulLoginSegue", sender: self)
    }
}
