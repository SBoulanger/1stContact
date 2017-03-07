//
//  VerifyViewController.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 3/2/16.
//  Copyright © 2016 Samuel Boulanger. All rights reserved.
//
import UIKit
import AddressBook
import CoreData
import Contacts
import ContactsUI
import Foundation

class VerifyViewController: UIViewController,CNContactViewControllerDelegate {
    //labels
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var numberVerifyLabel: UILabel!
    //buttons
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!

    var contact: CNContact!
    var phoneNumber: String!
    var contactIndex: Int = 0
    var store = CNContactStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        //editcontact = contact.mutableCopy() as! CNMutableContact
        phoneNumber = getPhoneNumber(contact)
        setUpInterface()
        displayWarnings()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //self.navigationController?.navigationBarHidden = true
        
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey,CNContactViewController.descriptorForRequiredKeys()] as [Any]
        
        do {
            let contactRefetched = try AppDelegate.getAppDelegate().contactStore.unifiedContact(withIdentifier: contact.identifier, keysToFetch: keysToFetch as! [CNKeyDescriptor])
            contact = contactRefetched
        }
        catch {
            AppDelegate.getAppDelegate().showMessage("Error with Contact.")
        }
        
        phoneNumber = getPhoneNumber(contact)
        //set up name label
        nameLabel.text = getNameLabel(contact.givenName, lastname: contact.familyName) //get label text
        //set up number label
        numberVerifyLabel.text = "use this number \(phoneNumber)?"
        displayWarnings()
        print("view will appear")
    }
    
    //----------------------------ACTIONS-------------------------------//
    @IBAction func yesButtonPressed(_ sender: AnyObject) {
        print("Yes button pressed")
        
        let defaults = UserDefaults.standard
        let contactData = NSKeyedArchiver.archivedData(withRootObject: contact) //create savable data from contact
        defaults.set(contactData, forKey: "contact") //save your contact
        defaults.set(true, forKey: "contactSelected") //set contact selected to true
        defaults.synchronize()
        self.performSegue(withIdentifier: "Instruction", sender: self) //go to next Instructions page
    }
    @IBAction func noButtonPressed(_ sender: AnyObject) {
        print("No button pressed")
        navigationController?.popToRootViewController(animated: true) //go back to welcome page
    }
    @IBAction func notNumButtonPressed(_ sender: AnyObject) {
        changePhoneNumber()
        numberVerifyLabel.text = "use this number \(phoneNumber)?"
    }
    @IBAction func editContactPressed(_ sender: AnyObject) {
        let controller = CNContactViewController(for:contact)
        controller.delegate = self
        controller.navigationItem.rightBarButtonItem? = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit,target: self, action: nil)
        //presents the view controller and shows the navigation bar so they can return back
        self.navigationController?.pushViewController(controller, animated: false)
//        self.navigationController?.navigationBarHidden = false
    }
    //-------------------------INTERFACE------------------------------//
    func setUpInterface(){
        //sets up the buttons
        makeCircleButton(noButton) //set up yes buttpn
        noButton.titleLabel?.font = ButtonStyle.font
        makeCircleButton(yesButton) //set up no button
        yesButton.titleLabel?.font = ButtonStyle.font
        
        //set up the question label style
        questionLabel.font.withSize(LabelStyle.smallFontSize)
        
        //set up the name label style
        nameLabel.font.withSize(LabelStyle.largeFontSize)


    }
    //makes a square button a circle
    func makeCircleButton(_ button: UIButton){
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
    }
    //returns the appropriate label for the amount of names present
    func getNameLabel(_ firstname:String, lastname:String) -> String {
        if (firstname.isEmpty && lastname.isEmpty){return "NO NAME"}
        if (firstname.isEmpty){return lastname}
        if (lastname.isEmpty){return firstname}
        return "\(firstname), \(lastname)"
    }
    //populate the warning label if properties missing
    func displayWarnings(){
        var stringLabel = ""
        warningLabel.numberOfLines = 0
        if contact.givenName.isEmpty {
            warningLabel.numberOfLines += 1
            stringLabel += "⭐️  first name missing\n"
        }
        if contact.familyName.isEmpty {
            warningLabel.numberOfLines += 1
            stringLabel += "⭐️  last name missing\n"
        }
        print(contact.phoneNumbers.count)
        if contact.phoneNumbers.count == 0 {
            print("here")
            warningLabel.numberOfLines += 1
            stringLabel += "⭐️  phone number missing"
        }
        warningLabel.text = stringLabel
    }
    //creates the phone number property
    func getPhoneNumber(_ contact:CNContact) -> String {
        var number = ""
        var priority = 1000
        if contact.phoneNumbers.count == 1 {
            let ref = contact.phoneNumbers[0].value 
            print(ref.stringValue)
            number = ref.stringValue
            contactIndex = 0
        }
        else {
            var i = 0
            for reference in contact.phoneNumbers {
                if (reference.label == "_$!<Main>!$_"){
                    let ref = reference.value 
                    number = ref.stringValue
                    contactIndex = i
                    break
                }
                else if (reference.label == "iPhone"){
                    let ref = reference.value 
                    number = ref.stringValue
                    priority = 1
                    contactIndex = i
                }
                else if (reference.label == "_$!<Mobile>!$_"){
                    if priority > 2 {
                        let ref = reference.value 
                        number = ref.stringValue
                        priority = 2
                        contactIndex = i
                    }
                }
                else if (reference.label == "_$!<HomeFAX>!$_"){
                    if priority > 3 {
                        let ref = reference.value 
                        number = ref.stringValue
                        priority = 3
                        contactIndex = i
                    }
                }
                else if (reference.label == "_$!<WorkFAX>!$_"){
                    if priority > 4 {
                        let ref = reference.value 
                        number = ref.stringValue
                        priority = 4
                        contactIndex = i
                    }
                }
                else if (reference.label == "_$!<Pager>!$_"){
                    if priority > 5 {
                        let ref = reference.value 
                        number = ref.stringValue
                        priority = 5
                        contactIndex = i
                    }
                }
                else if (reference.label == ""){
                    if priority > 6 {
                        let ref = reference.value 
                        number = ref.stringValue
                        priority = 6
                        contactIndex = i
                    }
                }
                i += 1
                
            }
        }
        return number
    }
    //changes the phone number property
    func changePhoneNumber() {
        if contact.phoneNumbers.count != 0 {
            if (contact.phoneNumbers.count == contactIndex+1){
                contactIndex = 0
            } else {
                contactIndex += 1
            }
            let ref = contact.phoneNumbers[contactIndex].value 
            phoneNumber = ref.stringValue
        }
    }
    
    //presents the contact view to choose a contact then
    func contactPicker(_ picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        self.contact = contact
    }
    

}
