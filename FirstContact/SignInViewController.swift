//
//  SignInViewController.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 3/15/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import UIKit
import AWSMobileHubHelper



class SignInViewController: UIViewController {
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AnyObject>?
    
    @IBOutlet weak var customUserIdField: UITextField!
    @IBOutlet weak var customPasswordField: UITextField!
    @IBOutlet weak var customForgotPasswordButton: UIButton!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var customCreateAccountButton: UIButton!
    @IBOutlet weak var countryCodeField: UITextField!
    
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var phoneNumberField: UITextField!
    var didSignInObserver: AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = UIColor.white
        /*didSignInObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignIn, object: AWSIdentityManager.default(), queue: OperationQueue.main, using: {(note: Notification) -> Void in
                print("LOGGED IN: ----------------------------------------")
            })
         */
        phoneNumberField.addTarget(self, action: #selector(editNumber), for: .editingChanged)
        countryCodeField.addTarget(self, action: #selector(editCountry), for: .editingChanged)
        
        signInButton.addTarget(self, action: #selector(self.handleCustomSignIn), for: .touchUpInside)
        signInButton.layer.cornerRadius = 3.0
        customCreateAccountButton.addTarget(self, action: #selector(self.handleUserPoolSignUp), for: .touchUpInside)
        customForgotPasswordButton.addTarget(self, action: #selector(self.handleUserPoolForgotPassword), for: .touchUpInside)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIView.animate(withDuration: 0.5, delay: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.alpha = 0.90
        }, completion: nil)
        self.customUserIdField.isHidden = true
        self.phoneNumberField.isHidden = false
        self.countryCodeField.isHidden = false
        self.toggleButton.setTitle("Username", for: .normal)
    }
    func handleLoginWithSignInProvider(_ signInProvider: AWSSignInProvider) {
        AWSSignInManager.sharedInstance().login(signInProviderKey: signInProvider.identityProviderName, completionHandler: {(result: Any?, authState:AWSIdentityManagerAuthState, error: Error?) in
            // If no error reported by SignInProvider, discard the sign-in view controller.
            if error == nil {
                print("Sign In Successful")
                DispatchQueue.main.async(execute: {
                    AppDelegate.getAppDelegate().dataHub.setUpAWS()
                    AppDelegate.getAppDelegate().dataHub.contactsVC.setUpLogButton()
                    self.dismiss(animated: true, completion: nil)
                    //_ = self.navigationController?.popToRootViewController(animated: true)
                })
            }
            print("result = \(result), error = \(error)")
        })
    }
    @IBAction func toggleButtonPressed(_ sender: Any) {
        if (toggleButton.titleLabel?.text == "Username"){
            self.customUserIdField.isHidden = false
            self.phoneNumberField.isHidden = true
            self.countryCodeField.isHidden = true
            self.toggleButton.setTitle("Phone Number", for: .normal)
        } else {
            self.phoneNumberField.isHidden = false
            self.countryCodeField.isHidden = false
            self.customUserIdField.isHidden = true
            self.toggleButton.setTitle("Username", for: .normal)
        }
        
    }
    @IBAction func dismissX(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
