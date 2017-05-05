//
//  SendContactViewController.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 4/21/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import Contacts
import ContactsUI

class SendContactViewController : UIViewController, UITextFieldDelegate,MFMessageComposeViewControllerDelegate {
    
    var dataHub : DataHub!
    
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var numberField: UITextField!
    
    
    @IBOutlet weak var zeroButton: UIButton!
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var nineButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    var keyBoard:[UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        self.numberField.isUserInteractionEnabled = false
        self.deleteButton.isHidden = true
        
        self.dataHub = AppDelegate.getAppDelegate().dataHub
        
        self.numberField.addTarget(self, action: #selector(editNumber), for: .editingChanged)
        
        keyBoard = [zeroButton,oneButton,twoButton,threeButton,fourButton,fiveButton,sixButton,sevenButton,eightButton,nineButton]
        
        for i in 0..<keyBoard.count {
            keyBoard[i].layer.cornerRadius = keyBoard[i].bounds.width * 0.5
            keyBoard[i].layer.borderColor = UIColor(colorLiteralRed: 10/255, green: 255/255, blue: 0/255, alpha: 0.6).cgColor
            keyBoard[i].layer.borderWidth = 1.3
        }
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.imageEdgeInsets = UIEdgeInsetsMake(30.0, 50.0, 50.0, 30.0)
        
    }
    
    @IBAction func exitPressed(_ sender: Any) { self.dismiss(animated: true, completion: nil)}
    
    @IBAction func oneButtonPressed(_ sender: Any) {
        self.numberField.text?.append("1")
        checkToHideDel()
        editNumber(sender: self.numberField)
    }
    @IBAction func twoButtonPressed(_ sender: Any) {
        self.numberField.text?.append("2")
        checkToHideDel()
        editNumber(sender: self.numberField)
    }
    @IBAction func threeButtonPressed(_ sender: Any) {
        self.numberField.text?.append("3")
        checkToHideDel()
        editNumber(sender: self.numberField)
    }
    
    @IBAction func fourButtonPressed(_ sender: Any) {
        self.numberField.text?.append("4")
        checkToHideDel()
        editNumber(sender: self.numberField)
    }
    
    @IBAction func fiveButtonPressed(_ sender: Any) {
        self.numberField.text?.append("5")
        checkToHideDel()
        editNumber(sender: self.numberField)
    }
    
    @IBAction func sixButtonPressed(_ sender: Any) {
        self.numberField.text?.append("6")
        checkToHideDel()
        editNumber(sender: self.numberField)
    }
    
    @IBAction func sevenButtonPressed(_ sender: Any) {
        self.numberField.text?.append("7")
        checkToHideDel()
        editNumber(sender: self.numberField)
    }
    
    @IBAction func eightButtonPressed(_ sender: Any) {
        self.numberField.text?.append("8")
        checkToHideDel()
        editNumber(sender: self.numberField)
    }
    
    @IBAction func nineButtonPressed(_ sender: Any) {
        self.numberField.text?.append("9")
        checkToHideDel()
        editNumber(sender: self.numberField)
    }
    
    @IBAction func zeroButtonPressed(_ sender: Any) {
        self.numberField.text?.append("0")
        checkToHideDel()
        editNumber(sender: self.numberField)
    }
    func checkToHideDel(){
        if self.numberField.text == "" {
            self.deleteButton.isHidden = true
        } else {
            self.deleteButton.isHidden = false
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        if (self.numberField.text != ""){
            self.numberField.text?.remove(at: (self.numberField.text?.index(before: (self.numberField.text?.endIndex)!))!)
        }
        checkToHideDel()
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        sendTextMessage([self.numberField.text!], body: createMessage(contact: dataHub.getContact(), share: dataHub.share), contact: dataHub.getContact())
    }
    
    
    //creates the text message and presents the view for the user to send
    func sendTextMessage(_ recipients:[String],body:String,contact: FCContact) {
        print("sendTextMessage() entered")
        if MFMessageComposeViewController.canSendAttachments() {
            print("MFMessageComposeViewController can send attactments")
            let controller = MFMessageComposeViewController()
            controller.messageComposeDelegate = self
            controller.recipients = recipients
            controller.body = body
            let contactData = getVCard(contact.encode(),share:dataHub.share)
            controller.addAttachmentData(contactData, typeIdentifier: "Apple Vcard", filename: "\(contact.id*13).vcf")
            
            self.present(controller, animated: false, completion: nil)
            
        }
        else {
            print("message cant send")
        }
        print("send text message done")
    }
    //gets the message that will be sent with the text
    func createMessage(contact: FCContact, share:[Int]) -> String {
        
        var string = ""
        
        if share.contains(4){
            string += "Instagram : \(contact.instagram!)\n"
        }
        if share.contains(5){
            string += "Snapchat : \(contact.snapchat!)\n"
        }
        
        //string += "\"The miracle is this: the more we share the more we have.\" -Leonard Nimoy 🖖\n"
        string += "Don't forget to download 1stContact to make this process even quicker!\n"
        string += "https://itunes.apple.com/us/app/1stcontact/id1205752876?mt=8"
        
        return string
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult){
        /*This method is called when the user taps one of the buttons to dismiss the message composition interface. Your implementation of this method should dismiss the view controller and perform any additional actions needed to process the sending of the message. The result parameter lets you know whether the user chose to cancel or send the message or whether sending the message failed.*/
        self.dismiss(animated: true, completion: nil)
    }
    //MOVE
    //gets the card that will be sent over text
    func getVCard(_ contact:Dictionary<String, AnyObject>,share:[Int]) -> Data {
        var data : Data = Data()
        var cncontactsV = [CNContact]()
        do {
            print("do")
            print("\(share)")
            let contactCN = CNMutableContact()
            if (share.contains(0)){
                print("names added")
                contactCN.givenName  = contact["firstName"] as! String
                contactCN.familyName = contact["lastName"] as! String
            }
            if (share.contains(1)){
                print("number added")
                let phoneNumber = [CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: contact["phoneNumber"] as! String) )]
                contactCN.phoneNumbers = phoneNumber
            }
            if (share.contains(2)){
                print("email added")
                let email = [CNLabeledValue(label: CNLabelHome, value: contact["email"] as! NSString)]
                contactCN.emailAddresses = email
            }
            //cncontactsV.append(contactCN)
            try data = CNContactVCardSerialization.data(with: [contactCN])
        } catch {
            print("\(error)")
        }
        return data
    }
    func editNumber(sender: UITextField){
        if (sender.text?.characters.count)! > 0 {
            var editor : String! = sender.text
            editor = String(editor.characters.filter { "01234567890".characters.contains($0) })
            sender.text = AppDelegate.getAppDelegate().formatNumber(number: editor!)
        }
    }
    
    
}
