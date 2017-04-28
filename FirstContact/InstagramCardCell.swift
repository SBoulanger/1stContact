//
//  InstagramCardCell.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 3/14/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import MMCardView

class InstagramCardCell: CardCell, CardCellProtocol, UITextFieldDelegate {
    
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var instagramTextField: UITextField!
    
    var controller : ContactCardViewController!
    
    @IBOutlet weak var goButton: UIButton!
    
    var dataHub: DataHub!
    var contact: FCContact!
    var contactIndex: Int!
    
    let instaHookRoot = "instagram://user?username="
    let instagramweb  = "http://instagram.com"
    
    
    public static func cellIdentifier() -> String {
        return "InstagramCard"
    }
    
    override func awakeFromNib() {
        
        self.titleLabel.text = "Instagram"
        self.instagramTextField.delegate = self
        
        super.awakeFromNib()
        
    }
    func setUpView(controller: ContactCardViewController){
        
        self.controller = controller
        
        self.dataHub = AppDelegate.getAppDelegate().dataHub
        
        print(contact)
        
        self.titleLabel.text = contact.instagram
        
        self.instagramTextField.text = contact.instagram
        
        self.instagramTextField.addTarget(self, action: #selector(self.checkEdited), for: UIControlEvents.editingChanged)
        self.saveButton.isHidden = true
        self.saveButton.layer.cornerRadius = 3.5
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
    func checkEdited(sender:UITextField!){
        print("checkEdited")
        if instagramTextField.text != contact.instagram{
            self.saveButton.isHidden = false
        } else {
            self.saveButton.isHidden = true
        }
    }
    func throwUpInstagramAlert(){
        AppDelegate.getAppDelegate().showMessage("👻❓")
    }

    
    @IBAction func saveButtonPress(_ sender: Any) {
        print("SaveButtonPressed")
        self.contact.instagram = instagramTextField.text
        
        if self.contact.me == true {
            dataHub.updateContact(contact: contact)
        }else{
            var tempcontacts = dataHub.getContacts()
            tempcontacts[contactIndex] = contact
            dataHub.updateContacts(contacts: tempcontacts)
        }
        self.titleLabel.text = contact.instagram
        textFieldShouldReturn(self.instagramTextField)
        saveButton.isHidden = true
        controller.updateCells()
        
    }
    @IBAction func goButtonPressed(_ sender: Any) {
        do {
            let snapchatUrl = URL(string:instaHookRoot + self.instagramTextField.text!)
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
