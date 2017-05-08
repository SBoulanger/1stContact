//
//  ChangePasswordViewController.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 5/6/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import UIKit
import AWSCore
import AWSMobileHubHelper
import AWSCognitoUserPoolsSignIn

class ChangePasswordViewController : UIViewController {
    
    @IBOutlet weak var oldPassField: UITextField!
    
    @IBOutlet weak var newPassField: UITextField!
    
    @IBOutlet weak var changeButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.changeButton.layer.cornerRadius = 3.5
        self.title = "Change Password"
        navigationController?.navigationBar.titleTextAttributes = ([NSFontAttributeName: UIFont(name:"KohinoorBangla-Light", size: 23)!,NSForegroundColorAttributeName: UIColor.green])
        self.navigationController?.navigationBar.barTintColor = UIColor.white

    }
    @IBAction func changeButtonPressed(_ sender: Any) {
        let oldPass = oldPassField.text
        let newPass = newPassField.text
        //let idProfile = UserPoolsIdentityProfile.sharedInstance()
        let pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
        //AWSCognitoUserPoolsSignInProvider.sharedInstance().setInteractiveAuthDelegate(self)
        
        let user = pool.currentUser()
        if oldPass == "" || newPass == "" {
            UIAlertView(title: "Missing Required Fields",
                        message: "Username / Password are required for registration.",
                        delegate: nil,
                        cancelButtonTitle: "Ok").show()
            return
        }
        //self.startPasswordAuthentication()
        print("change password call")
        user?.changePassword(oldPass!, proposedPassword: newPass!).continueWith(block: {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else {print("not strong");return nil}
            DispatchQueue.main.async(execute: {
                if let error = task.error as? NSError {
                    print(error)
                } else {
                    UIAlertView(title: "🔑🔄🗝", message: "Password changed successfully", delegate: nil, cancelButtonTitle: "Ok").show()
                    _ = strongSelf.navigationController?.popViewController(animated: true)
                }
            })
            print("end")
            return nil
        })
        
    }
}






    
