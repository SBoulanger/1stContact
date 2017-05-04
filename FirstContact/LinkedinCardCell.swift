//
//  LinkedinCardCell.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 5/3/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import UIKit
import MMCardView

class LinkedinCardCell: CardCell, CardCellProtocol, UITextFieldDelegate {
    
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var linkedInLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    //@IBOutlet weak var linkedinTextField: UITextField!
    
    var controller : ContactCardViewController!
    
    @IBOutlet weak var goButton: UIButton!
    
    var dataHub: DataHub!
    var contact: FCContact!
    var contactIndex: Int!
    
    var loginSucces = false
    
    var lidelegate : ContactCardViewController!
    
    public static func cellIdentifier() -> String {
        return "LinkedinCard"
    }
    
    override func awakeFromNib() {
        
        self.titleLabel.text = "Linkedin"
        //self.linkedinTextField.delegate = self
        
        super.awakeFromNib()
        
    }
    func setUpView(controller: ContactCardViewController){
        
        self.controller = controller
        self.titleLabel.text = ""
        self.dataHub = AppDelegate.getAppDelegate().dataHub
        self.signInButton.isHidden = false
        print(contact)
        
        if (self.contact.me){
            linkedInLabel.isHidden = true
            if (contact.linkedin == ""){
                signInButton.isHidden = false
                signOutButton.isHidden = true
            } else {
                signOutButton.isHidden = false
                signInButton.isHidden = true
            }
        } else {
            signOutButton.isHidden = true
            linkedInLabel.layer.borderColor = UIColor(colorLiteralRed: 13/255, green: 102/255, blue: 169/255, alpha: 1.0).cgColor
            linkedInLabel.layer.borderWidth = 1.5
            linkedInLabel.backgroundColor = UIColor.white
            linkedInLabel.layer.cornerRadius = 3.5
            if (contact.linkedin == ""){
                linkedInLabel.text = "No LinkedIn 👎"
            } else {
                linkedInLabel.text = "LinkedIn linked 👍"
            }
            linkedInLabel.textColor = UIColor(colorLiteralRed: 13/255, green: 102/255, blue: 169/255, alpha: 1.0)

        }
        if (self.contact.linkedin != ""){
            goButton.isHidden = false
        } else {
            goButton.isHidden = true
        }
        self.signOutButton.layer.cornerRadius = 3.5
        self.signInButton.layer.cornerRadius = 3.5
        self.goButton.layer.cornerRadius = 3.5

    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag: NSInteger = textField.tag + 1
        // Try to find next responder
        if let nextResponder: UIResponder? = textField.superview!.viewWithTag(nextTag){
            nextResponder?.becomeFirstResponder()
        }
        else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    /*func checkEdited(sender:UITextField!){
        print("checkEdited")
        if linkedinTextField.text != contact.instagram {
            self.signInButton.isHidden = false
        } else {
            self.signInButton.isHidden = true
        }
    }*/
    func throwUpInstagramAlert(){
        AppDelegate.getAppDelegate().showMessage("👻❓")
    }
    
    //13 102 169
    @IBAction func signInPress(_ sender: Any) {
        let sendSB = UIStoryboard(name: "LinkedInWebView", bundle: nil)
        print(sendSB)
        let sendVC = sendSB.instantiateInitialViewController()! as! LinkedInWebView
        sendVC.modalPresentationStyle = .popover
        sendVC.lidelegate = self
        self.controller.navigationController?.present(sendVC, animated: true, completion:nil)
    }
    func viewdone(){
        if (loginSucces == false){
            self.signInButton.isHidden = false
            self.signOutButton.isHidden = true
        } else {
            self.signOutButton.isHidden = false
            self.signInButton.isHidden = true
            self.goButton.isHidden = false
        }
    }
    @IBAction func signoutPressed(_ sender: Any) {
        self.contact.linkedin = ""
        self.dataHub.updateContact(contact: self.contact)
        self.signOutButton.isHidden = true
        self.goButton.isHidden = true
        self.signInButton.isHidden = false
    }
    @IBAction func goButtonPressed(_ sender: Any) {
       do {
            let snapchatUrl = URL(string:"linkedin://in/samuel-boulanger-ba945b133")
            if UIApplication.shared.canOpenURL(snapchatUrl!){
                UIApplication.shared.openURL(snapchatUrl!)
            } else {
                throwUpInstagramAlert()
            }
        }catch {
            throwUpInstagramAlert()
        }
 
    }
    
}
