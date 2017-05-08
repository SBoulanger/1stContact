//
//  SnapchatCardCell.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 3/14/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

//TODO throw snap alert doesnt work

import Foundation
import MMCardView

class SnapchatCardCell: CardCell, CardCellProtocol, UITextFieldDelegate {
    
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var snapchatTextField: UITextField!
    
    @IBOutlet weak var goButton: UIButton!
    var controller : ContactCardViewController!
    
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
    func setUpView(controller: ContactCardViewController){
        
        self.controller = controller
        
        print("SnapchatCardCell: setUpView()")
        print("------------- card being set up ---------")
        print(self.contact)
        print("----------------------------------")
        
        self.dataHub = AppDelegate.getAppDelegate().dataHub
        
        print(contact)
        
        self.titleLabel.text = contact.snapchat
        
        self.snapchatTextField.text = contact.snapchat
        
        self.snapchatTextField.addTarget(self, action: #selector(self.checkEdited), for: UIControlEvents.editingChanged)
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
        
        print("---------------- contact being saved ---------------------")
        print(self.contact)
        print("--------------------------------")
        
        print(self.contact)
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
        controller.updateCells()
        
    }

    @IBAction func goButtonPressed(_ sender: Any) {
        do {
            let snapchatUrl = URL(string:snapHookRoot + self.snapchatTextField.text!)
            if UIApplication.shared.canOpenURL(snapchatUrl!){
                UIApplication.shared.openURL(snapchatUrl!)
                print("")
            } else {
                var aCon = UIAlertController(title: "🆘", message: "There was an error", preferredStyle: UIAlertControllerStyle.alert)
                let dismissaction = UIAlertAction()
                aCon.addAction(dismissaction)
            }
        }catch {
            var aCon = UIAlertController(title: "🆘", message: "There was an error", preferredStyle: UIAlertControllerStyle.alert)
            let dismissaction = UIAlertAction()
            aCon.addAction(dismissaction)
        }
    }
}
