//
//  TestViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 1/23/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import SCLAlertView

class CreateUserFormViewController: FormViewController, LoginServiceDelegate {
    let loginService = LoginService()
    var blurredEffectView: UIVisualEffectView!
    var indicator: UIActivityIndicatorView!
    
    @IBAction func cancelCreateUser(_ sender: AnyObject) {
        let cancelAlertView = SCLAlertView()
        cancelAlertView.addButton("Exit Form") {
            self.dismiss(animated: true)
        }
        
        cancelAlertView.showTitle(
            "Create User",
            subTitle: "Are you sure you wish to exit this form?",
            duration: 0.0,
            completeText: "Cancel",
            style: .notice,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF)
    }
    
    @IBAction func submitForm(_ sender: AnyObject) {
        let submitAlertView = SCLAlertView()
        submitAlertView.addButton("Create") {
            self.createAccount()
        }
        
        submitAlertView.showTitle(
            "Create User",
            subTitle: "Create a new account with this information?",
            duration: 0.0,
            completeText: "Cancel",
            style: .notice,
            colorStyle: Style.mainColorHex,
            colorTextButton: 0xFFFFFF)
    }
    
    func createAccount() {
        let valuesDictionary = form.values()
        var toSubmit = [AnyHashable : Any] ()
        
        for key in valuesDictionary.keys {
            if let value = valuesDictionary[key] {
                if key == "birthday" {
                    toSubmit[key] = Utilities.dateToBirthday(date: (value as! Date))
                } else {
                    toSubmit[key] = value
                }
            }
        }
        
        if self.requiredFieldsFilled(userInfoKeys: Array(toSubmit.keys)) {
            self.blurView()
            self.indicator.startAnimating()
            loginService.createNewUser(userInfo: toSubmit)
        } else {
            SCLAlertView().showError("Create User", subTitle: "Please fill out all required fields.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginService.loginServiceDelegate = self
        
        self.indicator = Utilities.createActivityIndicator(center: self.parent!.view.center)
        self.parent!.view.addSubview(indicator)
        
        let blurEffect = UIBlurEffect(style: .dark)
        self.blurredEffectView = UIVisualEffectView(effect: blurEffect)
        self.blurredEffectView.frame = self.view.frame
        view.addSubview(self.blurredEffectView)
        self.blurredEffectView.alpha = 0;
        
        self.createForm()
    }
    
    func createForm() {
        self.form = Section("Required")
            <<< TextRow(){ row in
                row.title = "First Name"
                row.placeholder = "John"
                row.tag = "firstname"
                row.add(rule: RuleRequired())
            }
            <<< TextRow(){ row in
                row.title = "Last Name"
                row.placeholder = "Smith"
                row.tag = "lastname"
                row.add(rule: RuleRequired())
            }
            <<< IntRow(){
                $0.title = "Roster Number"
                $0.placeholder = "300"
                $0.tag = "roster"
                $0.add(rule: RuleRequired())
            }
            <<< PickerInlineRow<String>() {
                $0.title = "Admin Privileges"
                $0.options = Utilities.ADMIN_ARRAY
                $0.value = "None"    // initially selected
                $0.tag = "admin"
                $0.add(rule: RuleRequired())
            }
            <<< TextRow(){ row in
                row.title = "Class"
                row.placeholder = "Alpha Alpha"
                row.tag = "class"
                row.add(rule: RuleRequired())
            }
            <<< PickerInlineRow<String>() {
                $0.title = "Status"
                $0.options = Utilities.STATUS_ARRAY
                $0.value = "Active"    // initially selected
                $0.tag = "status"
                $0.add(rule: RuleRequired())
            }
            
            
            +++ Section("Optional")
            <<< TextRow(){ row in
                row.title = "Nickname"
                row.placeholder = "Fancy Pants"
                row.tag = "nickname"
            }
            <<< DateRow(){
                $0.title = "Birthday"
                $0.value = Date()
                $0.tag = "birthday"
            }
            <<< PhoneRow(){
                $0.title = "Phone Number"
                $0.placeholder = "555-555-5555"
                $0.tag = "phone"
            }
            <<< TextRow(){ row in
                row.title = "Expected Graduation"
                row.placeholder = "W2017"
                row.tag = "expectedGrad"
            }
            <<< TextRow(){ row in
                row.title = "Major"
                row.placeholder = "Music"
                row.tag = "major"
            }
            <<< TextRow(){ row in
                row.title = "SLO Address"
                row.placeholder = "1 Grand Ave"
                row.tag = "sloAddress"
            }
            <<< TextRow(){ row in
                row.title = "Section"
                row.placeholder = "Flute"
                row.tag = "section"
        }
    }
    
    func requiredFieldsFilled(userInfoKeys: [AnyHashable]) -> Bool {
        return userInfoKeys.contains("firstname")
            && userInfoKeys.contains("lastname")
            && userInfoKeys.contains("roster")
            && userInfoKeys.contains("class")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func successfullyLoginLogoutUser(password: String) {
        self.indicator.stopAnimating()
        SCLAlertView().showSuccess("Create User", subTitle: "Your account was created! Temporary password: \"\(password)\"").setDismissBlock {
            self.loginService.logoutCurrentUser(isCreate: true)
            self.dismiss(animated: true)
        }
    }
    
    func blurView() {
        UIView.animate(withDuration: Utilities.ANIMATION_DURATION) {
            self.blurredEffectView.alpha = 1.0
        }
    }
    
    func showErrorMessage(message: String) {self.indicator.stopAnimating()
        SCLAlertView().showError("Create User", subTitle: message).setDismissBlock {
            self.indicator.stopAnimating()
            self.blurredEffectView.alpha = 0
            self.blurredEffectView.layer.removeAllAnimations()
        }
    }
}
