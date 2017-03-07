//
//  ViewController.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 9/30/15.
//  Copyright © 2015 Samuel Boulanger. All rights reserved.
//



//------IMPORTS------//
import UIKit
import ContactsUI
import Contacts
import AVFoundation
import MessageUI

class WelcomeViewController: UIViewController, CNContactPickerDelegate,CNContactViewControllerDelegate {
    
    var rootController: UINavigationController?
    var window: UIWindow?
    var skipTutorial: Bool?
    var infoAnimated: Bool?
    @IBOutlet weak var createContactButton: UIButton!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    //contact that is selected
    var contact: CNContact!
    let defaults = UserDefaults.standard

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var contactInfoLabel: UILabel!
    
    override func viewDidLoad() {
        print("viewDidLoad() entered")
        super.viewDidLoad()
        infoAnimated = false
        skipTutorial = defaults.bool(forKey: "skipTutorial")
        
        infoLabel.isHidden = true
        contactInfoLabel.isHidden = true
        createContactButton.isHidden = false
        
        //style the welcomeLabel
        self.welcomeLabel.font = LabelStyle.font
        self.welcomeLabel.font.withSize(LabelStyle.largeFontSize)
        self.welcomeLabel.backgroundColor = LabelStyle.backgroundColor
        self.welcomeLabel.textColor = LabelStyle.fontColor
        
        //style the choose contact Button
        self.chooseButton.titleLabel?.font = ButtonStyle.font
        self.chooseButton.layer.cornerRadius = 5
        
        //style the info label
        self.infoLabel.font = UIFont(name: "KohinoorBangla-Light", size: 15)
        self.contactInfoLabel.font = UIFont(name: "KohinoorBangla-Light", size: 15)

        self.infoLabel.font.withSize(5)
        self.infoLabel.numberOfLines = 5
        self.contactInfoLabel.font.withSize(5)
        self.contactInfoLabel.numberOfLines = 5
        
        
        
        //hide the navigation bar
        //self.navigationController?.navigationBarHidden = true
        
        //animate the welcome label
        UIView.animate(withDuration: 2.0, animations: {
            self.welcomeLabel.frame.origin.y += 90
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //self.navigationController?.navigationBarHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if skipTutorial == false{
            showInfo()
        }
    }
    
    func showInfo(){
        if infoAnimated == false {
            self.infoLabel.alpha = 0.0
            self.contactInfoLabel.alpha = 0.0
            infoLabel.isHidden = false
            contactInfoLabel.isHidden = false
            UIView.animate(withDuration: 2.0, animations: {
                self.infoLabel.alpha = 1.0
                self.contactInfoLabel.alpha = 1.0
                self.infoAnimated = true
            })
        }
        else {
            infoLabel.isHidden = false
            contactInfoLabel.isHidden = false
        }
    }
    
    //prepare the view controller before segueing there
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        //pass the contact
        let destinationVC = segue.destination as! VerifyViewController
        destinationVC.contact = contact
        print(contact.phoneNumbers)
    }
    
    //presents the picker controller
    func getContact() {
        print("getContact() entered")
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.delegate = self
        present(contactPickerViewController, animated: true, completion: nil)
    }
    
    //presents the contact view to choose a contact then
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        self.contact = contact
        navigationController?.popViewController(animated: true)
        self.performSegue(withIdentifier: "Verify", sender: self)
    }
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        navigationController?.popViewController(animated: true)
        
    }
    
    //-------------ACTIONS----------------------//
    //go button was pressed
    @IBAction func goButtonPressed(_ sender: AnyObject) {
        print("goButtonPressed")
        AppDelegate.getAppDelegate().requestForAccess{ (granted) -> Void in
            if granted {self.getContact()}
        }
    }
    @IBAction func infoButtonPressed(_ sender: AnyObject) {
        infoAnimated = false
        showInfo()}
    
    func presentNewContact(){
        print("present new contact menu")
    }
    
    @IBAction func createContactButtonPressed(_ sender: AnyObject) {
        let controller = CNContactViewController(forNewContact: nil)
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: false)
        //self.navigationController?.navigationBarHidden = false
    }
    
}

