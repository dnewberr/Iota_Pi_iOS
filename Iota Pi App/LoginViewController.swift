//
//  LoginViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 10/27/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import SCLAlertView

class LoginViewController: UIViewController, LoginServiceDelegate, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let loginService = LoginService()
    var blurredEffectView: UIVisualEffectView!
    var indicator: UIActivityIndicatorView!

    @IBAction func attemptLogin(_ sender: AnyObject) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            self.blurView()
            self.loginService.attemptLogin(email: email, password: password)
        }
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        let forgotPasswordAlert = SCLAlertView()
        let emailText = forgotPasswordAlert.addTextField()
        emailText.text = self.emailTextField.text
        
        forgotPasswordAlert.addButton("Reset") {
            if let email = emailText.text {
                if !email.trim().isEmpty {
                    self.blurView()
                    self.loginService.resetPassword(email: email.trim())
                } else {
                    SCLAlertView().showError("Reset Password", subTitle: "Please enter your username or email.")
                }
            } else {
                SCLAlertView().showError("Reset Password", subTitle: "Please enter your username or email.")
            }
        }
        
        forgotPasswordAlert.showTitle(
            "Reset Password",
            subTitle: "Please enter your username or email",
            duration: 0.0,
            completeText: "Cancel",
            style: .info,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF)
    }
    
    // Necessary for logout to work
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
        self.blurView()
        self.loginService.checkIfLoggedIn()
        
        self.errorMessageLabel.alpha = 0;
        
        let keyboardDismissTap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(keyboardDismissTap)
    }
    
    // blurs the view and starts the loading screen indicator
    func blurView() {
        self.indicator.startAnimating()
        UIView.animate(withDuration: Utilities.ANIMATION_DURATION) {
            self.blurredEffectView.alpha = 1.0
        }
    }
    
    // Closes keyboard when tapped outside textfields
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // changes the first responder based on which textfield user is in when they push enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.emailTextField == textField {
            passwordTextField.becomeFirstResponder()
        } else if self.passwordTextField == textField {
            textField.resignFirstResponder()
            self.attemptLogin(textField)
        }
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* DELEGATE METHODS */
    
    func successfullyLoginLogoutUser(password: String) {
        self.indicator.stopAnimating()
        self.performSegue(withIdentifier: "successfulLoginSegue", sender: self)
    }
    
    // shows the error message if user can't be logged in with an animation
    func showErrorMessage(message: String) {
        self.indicator.stopAnimating()
        self.blurredEffectView.alpha = 0
        self.blurredEffectView.layer.removeAllAnimations()
        self.errorMessageLabel.text = message
        
        UIView.animate(withDuration: Utilities.ANIMATION_DURATION, animations: { () -> Void in
            self.errorMessageLabel.alpha = 1
        }) { (Bool) -> Void in
            UIView.animate(withDuration: Utilities.ANIMATION_DURATION, delay: 1.5, options: .curveEaseInOut, animations: { () -> Void in
                self.errorMessageLabel.alpha = 0
            }, completion: nil)
        }
    }
}
