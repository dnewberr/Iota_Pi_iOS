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
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
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
    
    // Necessary for logout to work
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}
    
    @IBAction func forgotPassword(_ sender: Any) {
        let forgotPasswordAlert = SCLAlertView()
        let emailText = forgotPasswordAlert.addTextField()
        emailText.text = self.emailTextField.text
        
        forgotPasswordAlert.showTitle(
            "Reset Password",
            subTitle: "Please enter your username or email",
            duration: 0.0,
            completeText: "Reset",
            style: .info,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF).setDismissBlock {
                if let email = emailText.text {
                    if !email.trim().isEmpty {
                        let fullEmail = email.contains("@") ? email : email + "@iotapi.com"
                        self.indicator.startAnimating()
                        self.blurView()
                        self.loginService.resetPassword(email: fullEmail)
                    } else {
                        SCLAlertView().showError("Reset Password", subTitle: "Please enter your username or email.")
                    }
                } else {
                    SCLAlertView().showError("Reset Password", subTitle: "Please enter your username or email.")
                }
        }
        
    }
    
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
        
        self.loginButton.layer.borderColor = Style.mainColor.cgColor
        self.loginButton.layer.borderWidth = 1
        
        let keyboardDismissTap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(keyboardDismissTap)
    }
    
    // Closes keyboard when tapped outside textfields
    func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
        self.blurredEffectView.layer.removeAllAnimations()
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
