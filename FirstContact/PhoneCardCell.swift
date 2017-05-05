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
    
    var controller : ContactCardViewController!
    
    var dataHub: DataHub!
    var contact: FCContact!
    var contactIndex: Int!
    
    public static func cellIdentifier() -> String {
        return "PhoneCard"
    }
    
    override func awakeFromNib() {
        
        self.titleLabel.text = "Phone Number"
        self.phoneTextField.delegate = self
        self.phoneTextField.addTarget(self, action: #selector(editNumber), for: .editingChanged)
        
        print("awakeFromNib")
        
        super.awakeFromNib()
        
    }
    func setUpView(controller: ContactCardViewController){
        self.dataHub = AppDelegate.getAppDelegate().dataHub
        
        self.controller = controller
        
        print("setUpView")
        
        self.saveButton.layer.cornerRadius = 3.5
        
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
        controller.updateCells()

    }
    func editNumber(sender: UITextField){
        if (sender.text?.characters.count)! > 0 {
            var editor : String! = sender.text
            editor = String(editor.characters.filter { "01234567890".characters.contains($0) })
            sender.text = AppDelegate.getAppDelegate().formatNumber(number: editor!)
        }
    }
    
}
