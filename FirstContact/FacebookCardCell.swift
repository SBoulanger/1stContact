//
//  FacebookCardCell.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 4/24/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import MMCardView
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit


class FacebookCardCell: CardCell, CardCellProtocol {
    
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    
    @IBOutlet weak var fbLabel: UILabel!
        
    @IBOutlet weak var fbButton: FBSDKLoginButton!
    
    var controller : ContactCardViewController!
    
    let FBURL = "fb://profile/?app_scoped_user_id="
    
    var dataHub: DataHub!
    var contact: FCContact!
    var contactIndex: Int!
    
    
    public static func cellIdentifier() -> String {
        return "FacebookCard"
    }
    
    override func awakeFromNib() {
        
        self.titleLabel.text = "Facebook"
        
        super.awakeFromNib()
        
    }
    func setUpView(controller: ContactCardViewController){
        
        print("FACEBOOK CELL ENTERED")
        self.titleLabel.text = ""
        print(self.contact.facebook)
        self.controller = controller
        fbButton.isHidden = false
        fbLabel.isHidden = false
        self.dataHub = AppDelegate.getAppDelegate().dataHub
        
        if (self.contact.me){
            fbLabel.isHidden = true
            if((FBSDKAccessToken.current()) != nil){
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id"]).start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil){
                        var result1 = result as! Dictionary<String,String>
                        self.contact.facebook = result1["id"]
                        self.dataHub.updateContact(contact: self.contact)
                    }else{
                        print("Error: \(String(describing: error))")
                    }
                })
            } else {
                print("FacebooCardCell: Not logged in, no AccessToken")
            }
        } else {
            fbButton.isHidden = true
            fbLabel.layer.borderColor = UIColor(colorLiteralRed: 45/255, green: 68/255, blue: 134/255, alpha: 1.0).cgColor
            fbLabel.layer.borderWidth = 1.5
            fbLabel.backgroundColor = UIColor.white
            fbLabel.layer.cornerRadius = 3.5
            if (contact.facebook == ""){
                fbLabel.text = "No Facebook 👎"
            } else {
                fbLabel.text = "Facebook connected 👍"
            }
            fbLabel.textColor = UIColor(colorLiteralRed: 45/255, green: 68/255, blue: 134/255, alpha: 1.0)
        }
        if (self.contact.facebook != ""){
            goButton.isHidden = false
        } else {
            goButton.isHidden = true
        }
        
    }
    
    @IBAction func goButtonPressed(_ sender: Any) {
        let fbUrl = URL(string: (FBURL + self.contact.facebook))
        if UIApplication.shared.canOpenURL(fbUrl!)
        {
            UIApplication.shared.openURL(fbUrl!)
            
        } else {
            //redirect to safari because the user doesn't have Instagram
            UIApplication.shared.openURL(URL(string: "http://facebook.com/")!)
        }
        
    }
    
    
    /*
    func fbLoginInitiate() {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile", "email"], handler: {(result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if (error != nil) {
                // Process error
                self.removeFbData()
            } else if result.isCancelled {
                // User Cancellation
                self.removeFbData()
            } else {
                //Success
                if result.grantedPermissions.contains("email") && result.grantedPermissions.contains("public_profile") {
                    //Do work
                    self.fetchFacebookProfile()
                } else {
                    //Handle error
                }
            }
        } as! FBSDKLoginManagerRequestTokenHandler)
    }
    */
    func removeFbData() {
        //Remove FB Data
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        FBSDKAccessToken.setCurrent(nil)
    }
    /*
    func fetchFacebookProfile()
    {
        if FBSDKAccessToken.current() != nil {
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if ((error) != nil) {
                    //Handle error
                } else {
                    //Handle Profile Photo URL String
                    let result1 = result as! Dictionary<String, Any>
                    let userId =  result1["id"] as! String
                    let profilePictureUrl = "https://graph.facebook.com/\(userId)/picture?type=large"
                    
                    let accessToken = FBSDKAccessToken.current().tokenString
                    let fbUser = ["accessToken": accessToken, "user": result]
                }
            })
        }
    }
 */
    
}
