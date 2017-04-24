//
//  PhoneCardCell.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 3/10/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import MMCardView

class PhoneCardCell: CardCell, CardCellProtocol, UITextFieldDelegate {
    
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    

    
    var dataHub: DataHub!
    var contact: FCContact!
    var contactIndex: Int!
    
    public static func cellIdentifier() -> String {
        return "PhoneCard"
    }
    
    override func awakeFromNib() {
        
        self.titleLabel.text = "Phone Number"
        self.phoneTextField.delegate = self
        
        print("awakeFromNib")
        
        super.awakeFromNib()
        
    }
    func setUpView(pcontact:FCContact, index: Int){
        self.dataHub = AppDelegate.getAppDelegate().dataHub
        
        self.contact = pcontact
        self.contactIndex = index
        print("setUpView")
        
        print(contact)
        
        self.titleLabel.text = contact.phoneNumber
        
        self.phoneTextField.text = contact.phoneNumber
        
        self.phoneTextField.addTarget(self, action: #selector(self.checkEdited), for: UIControlEvents.editingChanged)
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
        if phoneTextField.text != contact.phoneNumber {
            self.saveButton.isHidden = false
        } else {
            self.saveButton.isHidden = true
        }
    }

    @IBAction func saveButtonPress(_ sender: Any) {
        print("SaveButtonPressed")
        self.contact.phoneNumber = phoneTextField.text
        
        if self.contact.me == true {
            dataHub.updateContact(contact: contact)
        }else{
            var tempcontacts = dataHub.getContacts()
            tempcontacts[contactIndex] = contact
            dataHub.updateContacts(contacts: tempcontacts)
        }
        self.titleLabel.text = contact.phoneNumber
        textFieldShouldReturn(self.phoneTextField)
        saveButton.isHidden = true

    }
    
}
