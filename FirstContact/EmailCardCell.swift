//
//  EmailCardCell.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 3/14/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import MMCardView

class EmailCardCell: CardCell, CardCellProtocol, UITextFieldDelegate {
    
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!

    @IBOutlet weak var emailTextField: UITextField!
    
    
    
    var dataHub: DataHub!
    var contact: FCContact!
    var contactIndex: Int!
    
    public static func cellIdentifier() -> String {
        return "EmailCard"
    }
    
    override func awakeFromNib() {
        
        self.titleLabel.text = "Email"
        self.emailTextField.delegate = self
        
        super.awakeFromNib()
        
    }
    func setUpView(pcontact: FCContact, index: Int){
        self.dataHub = AppDelegate.getAppDelegate().dataHub
        self.contact = pcontact
        self.contactIndex = index
        print(contact)
        
        self.titleLabel.text = contact.email
        
        self.emailTextField.text = contact.email
        
        self.emailTextField.addTarget(self, action: #selector(self.checkEdited), for: UIControlEvents.editingChanged)
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
        if emailTextField.text != contact.email{
            self.saveButton.isHidden = false
        } else {
            self.saveButton.isHidden = true
        }
    }
    
    @IBAction func saveButtonPress(_ sender: Any) {
        print("SaveButtonPressed")
        self.contact.email = emailTextField.text
        
        if self.contact.me == true {
            dataHub.updateContact(contact: contact)
        }else{
            var tempcontacts = dataHub.getContacts()
            tempcontacts[contactIndex] = contact
            dataHub.updateContacts(contacts: tempcontacts)
        }
        self.titleLabel.text = contact.email
        textFieldShouldReturn(self.emailTextField)
        saveButton.isHidden = true
        
    }
    
}
