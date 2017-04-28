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
    
    var didSignInObserver: AnyObject!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = UIColor.white
        /*didSignInObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignIn, object: AWSIdentityManager.default(), queue: OperationQueue.main, using: {(note: Notification) -> Void in
                print("LOGGED IN: ----------------------------------------")
            })
         */
        
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
    @IBAction func dismissX(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
