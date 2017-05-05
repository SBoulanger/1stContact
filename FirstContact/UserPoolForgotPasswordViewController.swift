//
//  UserPoolForgotPasswordViewController.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.12
//
//

import Foundation
import UIKit
import AWSCognitoIdentityProvider
import AWSMobileHubHelper
import AWSCognitoUserPoolsSignIn

class UserPoolForgotPasswordViewController: UIViewController {
    
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?
    
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var countryCodeField: UITextField!
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var toggleButton: UIButton!
    @IBAction func onForgotPassword(_ sender: AnyObject) {
        
        let inputtext : String!
        if (toggleButton.titleLabel?.text != "Username"){
            inputtext = self.userName.text
        } else {
            var string : String!
            string = self.phoneNumberField.text
            inputtext = self.countryCodeField.text! + String(string.characters.filter { "01234567890".characters.contains($0) })
        }
        
        
        guard let username = inputtext, !username.isEmpty else {
            UIAlertView(title: "Missing Username or Phone Number",
                        message: "Please enter a valid user name or phone number.",
                        delegate: nil,
                        cancelButtonTitle: "Ok").show()
            return
        }
        
        self.user = self.pool?.getUser(self.userName.text!)
        self.user?.forgotPassword().continueWith(block: {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else {return nil}
            DispatchQueue.main.async(execute: {
                if let error = task.error as? NSError {
                    UIAlertView(title: error.userInfo["__type"] as? String,
                        message: error.userInfo["message"] as? String,
                        delegate: nil,
                        cancelButtonTitle: "Ok").show()
                } else {
                    strongSelf.performSegue(withIdentifier: "NewPasswordSegue", sender: sender)
                }
            })
            return nil
        })
        
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
        //self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userName.isHidden = true
        self.phoneNumberField.isHidden = false
        self.phoneNumberField.addTarget(self, action: #selector(editNumber), for: .editingChanged)
        self.countryCodeField.isHidden = false
        self.countryCodeField.addTarget(self, action: #selector(editCountry), for: .editingChanged)
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }

    @IBAction func toggleButtonPressed(_ sender: Any) {
        if (toggleButton.titleLabel?.text == "Username"){
            self.userName.isHidden = false
            self.phoneNumberField.isHidden = true
            self.countryCodeField.isHidden = true
            self.toggleButton.setTitle("Phone Number", for: .normal)
        } else {
            self.phoneNumberField.isHidden = false
            self.countryCodeField.isHidden = false
            self.userName.isHidden = true
            self.toggleButton.setTitle("Username", for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newPasswordViewController = segue.destination as? UserPoolNewPasswordViewController {
            newPasswordViewController.user = self.user
        }
    }
    func editNumber(sender: UITextField){
        if (sender.text?.characters.count)! > 0 {
            var editor : String! = sender.text
            editor = String(editor.characters.filter { "01234567890".characters.contains($0) })
            sender.text = AppDelegate.getAppDelegate().formatNumber(number: editor!)
        }
    }
    func editCountry(sender: UITextField){
        if (sender.text?.characters.count)! > 0 {
            var editor : String! = sender.text
            editor = String(editor.characters.filter { "01234567890".characters.contains($0) })
            sender.text = "+" + editor
        }
    }
}
