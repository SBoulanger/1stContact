//
//  NameCardCell.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 3/10/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import MMCardView

class NameCardCell: CardCell, CardCellProtocol, UITextFieldDelegate {

    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstNameTitle: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    var controller : ContactCardViewController!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var dataHub: DataHub!
    var contact: FCContact!
    var contactIndex: Int!
    
    public static func cellIdentifier() -> String {
        print("NameCardCell: cellIdentifier")
        return "NameCard"
    }
    
    override func awakeFromNib() {
        print("NameCardCell: awakeFromNib()")
                
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        
        self.saveButton.layer.cornerRadius = 3.5
        
        self.dataHub = AppDelegate.getAppDelegate().dataHub

        super.awakeFromNib()
    }
    func setUpView(controller: ContactCardViewController){
        print("NameCardCell: setUpView()")
        print("--------- contact being set up ------------")
        print(contact)
        print("--------------------------------------------")
        self.controller = controller
        self.titleLabel.text = ""
        self.firstNameTitle.text = self.contact.firstName + " " + self.contact.lastName
        
        print(self.contact)
        
        self.firstNameTextField.text = self.contact.firstName
        self.lastNameTextField.text = self.contact.lastName
        
        self.firstNameTextField.addTarget(self, action: #selector(self.checkEdited), for: UIControlEvents.editingChanged)
        self.lastNameTextField.addTarget(self, action: #selector(self.checkEdited), for: UIControlEvents.editingChanged)
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
        //print("NameCardCell: checkEdited")
        if firstNameTextField.text != contact.firstName || lastNameTextField.text != contact.lastName {
                self.saveButton.isHidden = false
        } else {
            self.saveButton.isHidden = true
        }
    }
    @IBAction func saveButtonPressed(_ sender: Any) {
        print("NameCardCell: SaveButtonPressed")
        self.contact.firstName = firstNameTextField.text
        self.contact.lastName = lastNameTextField.text
        
        if self.contact.me == true {
            dataHub.updateContact(contact: self.contact)
        }else{
            var tempcontacts = dataHub.getContacts()
            tempcontacts[contactIndex] = self.contact
            dataHub.updateContacts(contacts: tempcontacts)
        }
        self.firstNameTitle.text = self.contact.firstName + " " + self.contact.lastName
        textFieldShouldReturn(self.firstNameTextField)
        textFieldShouldReturn(self.lastNameTextField)
        saveButton.isHidden = true
        controller.updateCells()
    }

}
