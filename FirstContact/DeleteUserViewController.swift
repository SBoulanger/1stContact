//
//  DeleteUserViewController.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 5/7/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import UIKit
import AWSCore
import AWSCognitoUserPoolsSignIn
import AWSMobileHubHelper
import FBSDKLoginKit

class DeleteUserViewController : UIViewController {
    
    @IBOutlet weak var deleteButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.deleteButton.layer.cornerRadius = self.deleteButton.frame.width/2
        self.navigationController?.navigationBar.isHidden = false
        self.title = "Delete User"
        navigationController?.navigationBar.titleTextAttributes = ([NSFontAttributeName: UIFont(name:"KohinoorBangla-Light", size: 23)!,NSForegroundColorAttributeName: UIColor.green])
        self.navigationController?.navigationBar.barTintColor = UIColor.white

    }
    func deleteUser(){
        let pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)

        let user = pool.currentUser()
        
        user?.delete().continueOnSuccessWith(block: {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else {print("not strong");return nil}
            DispatchQueue.main.async(execute: {
                if let error = task.error as? NSError {
                    print(error)
                } else {
                    UIAlertView(title: "🖖", message: "User successfully deleted", delegate: nil, cancelButtonTitle: "Ok").show()
                    
                    
                    
                    AppDelegate.getAppDelegate().dataHub.wipeData()
                    if (AWSSignInManager.sharedInstance().isLoggedIn) {
                        AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?,authState: AWSIdentityManagerAuthState, error: Error?) in
                            print("logged out")
                            FBSDKLoginManager().logOut()
                        })
                    }
                    
                    var contact = FCContact()
                    contact.me = true
                    AppDelegate.getAppDelegate().dataHub.updateContact(contact: contact)
                   _ = strongSelf.navigationController?.popViewController(animated: true)
                }
            })
            return nil
        })

    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let actionHandler = {(action:UIAlertAction!) -> Void in
            self.deleteUser()
        }
        let alertController = UIAlertController(title: "⁉️", message: "Are you sure you want to delete your account?", preferredStyle: UIAlertControllerStyle.alert)
        
        let dismissHandler = {(action:UIAlertAction!) -> Void in
            print("Not Sure")
        }
        
        let dismissAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: dismissHandler)
        let sendAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: actionHandler)
        
        alertController.addAction(dismissAction)
        alertController.addAction(sendAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
