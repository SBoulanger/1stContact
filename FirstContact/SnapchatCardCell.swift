//
//  SnapchatCardCell.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 3/14/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import MMCardView

class SnapchatCardCell: CardCell, CardCellProtocol, UITextFieldDelegate {
    
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var snapchatTextField: UITextField!
    
    
    
    var dataHub: DataHub!
    var contact: FCContact!
    var contactIndex: Int!
    
    let snapHookRoot = "snapchat://add/"
    let snapchatWeb  = "http://snapchat.com"
    
    public static func cellIdentifier() -> String {
        return "SnapchatCard"
    }
    
    override func awakeFromNib() {
        
        self.titleLabel.text = "Snapchat"
        self.snapchatTextField.delegate = self
        
        super.awakeFromNib()
        
    }
    func setUpView(){
        self.dataHub = AppDelegate.getAppDelegate().dataHub
        
        print(contact)
        
        self.titleLabel.text = contact.snapchat
        
        self.snapchatTextField.text = contact.snapchat
        
        self.snapchatTextField.addTarget(self, action: #selector(self.checkEdited), for: UIControlEvents.editingChanged)
        self.saveButton.isHidden = true
        
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
        if snapchatTextField.text != contact.snapchat{
            self.saveButton.isHidden = false
        } else {
            self.saveButton.isHidden = true
        }
    }
    func throwUpSnapchatAlert(){
        AppDelegate.getAppDelegate().showMessage("👻❓")
    }
    
    @IBAction func saveButtonPress(_ sender: Any) {
        print("SaveButtonPressed")
        self.contact.snapchat = snapchatTextField.text
        
        if self.contact.me == true {
            dataHub.updateContact(contact: contact)
        }else{
            var tempcontacts = dataHub.getContacts()
            tempcontacts[contactIndex] = contact
            dataHub.updateContacts(contacts: tempcontacts)
        }
        self.titleLabel.text = contact.snapchat
        textFieldShouldReturn(self.snapchatTextField)
        saveButton.isHidden = true
        
    }

    @IBAction func goButtonPressed(_ sender: Any) {
        do {
            let snapchatUrl = URL(string:snapHookRoot + self.snapchatTextField.text!)
            if UIApplication.shared.canOpenURL(snapchatUrl!){
                UIApplication.shared.openURL(snapchatUrl!)
                print("")
            } else {
                throwUpSnapchatAlert()
            }
        }catch {
            print("caught")
            throwUpSnapchatAlert()
        }
    }
}
