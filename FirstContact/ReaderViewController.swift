//
//  ReaderViewController.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 11/9/15.
//  Copyright © 2015 Samuel Boulanger. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Contacts
import ContactsUI
import MessageUI

class ReaderViewController : UIViewController, AVCaptureMetadataOutputObjectsDelegate, MFMessageComposeViewControllerDelegate {
    
    //@IBOutlet weak var backButton: UIButton!
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    //var swipeView:UIView?
    var window: UIWindow?
    var contact: FCContact?
    var newestContact: FCContact!
    
    var contactInfoArray = [String]()

    var infoAnimated: Bool?
    var skipTutorial: Bool?

    var qrcodedone = false
    
    @IBOutlet weak var ufoImageView: UIImageView!
    @IBOutlet weak var ufoButton: UIButton!
    
    let defaults = UserDefaults.standard
    var info : String!
    
    var dataHub:DataHub!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Reader: INITIALIZATION")
        self.dataHub = AppDelegate.getAppDelegate().dataHub
        initQRCaptureCamera()
        //let button = UIButton(frame: ufoImageView.frame)
        //ufoButton.backgroundColor = UIColor.clear
        ufoButton.addTarget(nil, action: #selector(AppDelegate.getAppDelegate().container.moveUp), for: UIControlEvents.touchUpInside)
        //self.view.addSubview(button)
    }
    
    func initQRCaptureCamera(){
        // Create a media video capture device object
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        // Create a capture input class
        let input: AnyObject! //video input
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
            print("There was an error \(error.localizedDescription)")
            input = nil
        }
        //set the focus mode to always focus
        do {
            try captureDevice?.lockForConfiguration()
            captureDevice?.focusMode = .continuousAutoFocus
            captureDevice?.unlockForConfiguration()

        } catch let error as NSError {
            //captureDevice.focusMode = .ContinuousAutoFocus
            print("Could not unlock the camera configuriation \(error.localizedDescription)")
        }
        
        //TODO add a try block
        // init the video and set the input
        captureSession = AVCaptureSession()
        if (input != nil){
            captureSession?.addInput(input as! AVCaptureInput)
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //specify the data as QRCode
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            // create the video layer and ass it to the view
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
        
            view.layer.addSublayer(videoPreviewLayer!)
            // start
            captureSession?.startRunning()
            //create the found qrcode view box
            qrCodeFrameView = UIView()
            qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView?.layer.borderWidth = 2
        
            view.addSubview(qrCodeFrameView!)
        
            //make the view in front of the camera view
            view.bringSubview(toFront: qrCodeFrameView!)
            //logo to front
            //view.bringSubview(toFront: ufoButton)
            //back button to front
        }
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        //make sure there is something found
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            info = "No QR code is detected"
            return
        }
        //get the qr data object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        //make sure it is a qrcode object
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            //set the box around the qrcode
            qrCodeFrameView?.frame = barCodeObject.bounds
            //make sure there is data
            if metadataObj.stringValue != nil {
                //get contact info from object
                info = metadataObj.stringValue
                //make sure processing only happens once
                if !qrcodedone {
                    //get the info from the data string
                    print(info)
                    contactInfoArray = AppDelegate.getAppDelegate().dataHub.getContactInfo(info: info)
                    if contactInfoArray[0] != "nil" {
                        if ((info.range(of: "remote")) != nil){
                            var stringArray = contactInfoArray[0].components(separatedBy: ",")
                            var shareIntArray: [Int]! = []
                            for i in stringArray {
                                shareIntArray.append(Int(i)!)
                            }
                            print("qrcodedone is now true")
                            qrcodedone = true
                            AppDelegate.getAppDelegate().dataHub.getAWSContent(url: contactInfoArray[1], share: shareIntArray) {
                                let actionHandler = {(action:UIAlertAction!) -> Void in
                                    self.qrcodedone = false
                                    print("qrcodedone is now false ACTIONHANDLER")
                                }
                                print("if (self.newestContact != nil")
                                if (self.newestContact != nil){
                                    print("self.newestContact != nil")
                                    if (self.newestContact.firstName + self.newestContact.lastName == ""){
                                        print("showMessage()")
                                        self.showMessage("🚀", title: "Want to add NO NAME to your Contacts?",actionHandler: actionHandler)
                                    } else {
                                        print("showMessage() 2")
                                        self.showMessage("🚀", title: "Want to add \(self.newestContact.firstName!) \(self.newestContact.lastName!) to your contacts?",actionHandler: actionHandler)
                                    }
                                } else {
                                    print("newestContact is not being ")
                                }
                                
                            }
                            
                            
                        } else {
                            let newcontact = FCContact(first: contactInfoArray[0], last: contactInfoArray[1], phoneNumber: contactInfoArray[2], email: contactInfoArray[3], snapchat: contactInfoArray[4], instagram: contactInfoArray[5], facebook: contactInfoArray[6])
                        
                            print("created new contact")
                            qrcodedone = true
                            //create the send text message action
                            let actionHandler = {(action:UIAlertAction!) -> Void in
                                print("add new contact")
                                AppDelegate.getAppDelegate().dataHub.addContact(contact: newcontact)
                                print("refreshed dataHub Contacts")
                                self.qrcodedone = false
                            }
                            //ask if they will be sending their contact through a text
                        
                            if (newcontact.firstName+newcontact.lastName == ""){
                                showMessage("🚀", title: "Want to add NO NAME to your Contacts?",actionHandler: actionHandler)
                            } else {
                                showMessage("🚀", title: "Want to add \(newcontact.firstName) \(newcontact.lastName) to your contacts?",actionHandler: actionHandler)
                            }
                        }
                    } else {
                        print("got nil when getting contact")
                        let alertController = UIAlertController(title: "Error", message: "Not a contact code...", preferredStyle: UIAlertControllerStyle.alert)
                        let dismissAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
                        alertController.addAction(dismissAction)
                        present(alertController, animated: true, completion: nil)
                        self.qrcodedone = false
                    }
                    self.qrcodedone = true
                }
                print("qrcode not done")
                
            }
            else {
                print("it is nil")
            }
        }
        print("before barCodeObject")
        let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
        print("barCodeObject")
        qrCodeFrameView?.frame = barCodeObject.bounds
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
        didFinishWith result: MessageComposeResult){
            /*This method is called when the user taps one of the buttons to dismiss the message composition interface. Your implementation of this method should dismiss the view controller and perform any additional actions needed to process the sending of the message. The result parameter lets you know whether the user chose to cancel or send the message or whether sending the message failed.*/
            self.dismiss(animated: true, completion: nil)
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
                let contactData = getVCard([contact.encode()])
                controller.addAttachmentData(contactData, typeIdentifier: "Apple Vcard", filename: "contact.vcard")

                self.present(controller, animated: false, completion: nil)
                
            }
            else {
                print("message cant send")
            }
        print("send text message done")
    }
    //gets the message that will be sent with the text
    func createMessage(_ first:String, last: String, number: String) -> String {
        
        let string = "\"The miracle is this: the more we share the more we have.\" -Leonard Nimoy 🖖"
        
        return string
    }
    
    //shows the alert message when a qrcode was successfully read
    func showMessage(_ message: String, title: String, actionHandler: @escaping (_ accessGranted: UIAlertAction) -> Void) {
        print("showMessage() class called")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let dismissHandler = {(action:UIAlertAction!) -> Void in
            self.qrcodedone = false
        }
        
        let dismissAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: dismissHandler)
        let sendAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: actionHandler)
        
        alertController.addAction(dismissAction)
        alertController.addAction(sendAction)
        
        print("qrcode set to not done")
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MOVE
    //creates the contact read to the phones contact list
    func createContact(_ first:String, last: String, number: String) -> CNMutableContact {
        let newContact = CNMutableContact()
        
        
        
        newContact.givenName = first
        newContact.familyName = last
        newContact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: number) )]
        
        do {
            let saveRequest = CNSaveRequest()
            saveRequest.add(newContact, toContainerWithIdentifier: nil)
            try AppDelegate.getAppDelegate().contactStore.execute(saveRequest)
            } 
        catch {
            AppDelegate.getAppDelegate().showMessage("Could not save Contact.")
        }
        return newContact
    }
    
    //MOVE
    //gets the card that will be sent over text
    func getVCard(_ contacts:[Dictionary<String, AnyObject>]) -> Data {
        var data:Data
        data = Data()
        var cncontactsV = [CNContact]()
        do {
            for i in contacts {
                var contact = CNMutableContact()
                contact.givenName = i["firstName"] as! String
                contact.familyName = i["lastName"] as! String
                var phoneNumber = [CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: i["phoneNumber"] as! String) )]
                contact.phoneNumbers = phoneNumber
            }
            try data = CNContactVCardSerialization.data(with: cncontactsV as! [CNContact])
        } catch {
            print("\(error)")
        }
        return data
    }
    
    
    func getContactInfo(info:String) -> [String]{
        let check = info.range(of: "FirstContact/*")
        print("is a first contact string \(check)")
        //make sure the code scanned a FirstContact Code
        if check == nil {
            return ["nil"]
        }
        else {
            //populate the contactInfoArray
            let removeRange = (info.startIndex ..< (check?.upperBound)!)
            let nString = info.replacingCharacters(in: removeRange, with: "")
            return recursiveGetValues(nString,contactInfoArray: [])
        }
    }
    //recursively gets the values in a formatted string
    func recursiveGetValues(_ string:String,contactInfoArray:[String]) -> [String]{
        var newcontactArray = contactInfoArray
        let range = string.range(of: "/*")
        if range == nil {
            newcontactArray.append(string)
            print(contactInfoArray)
            return newcontactArray
        }
        let startIndex = range?.lowerBound
        newcontactArray.append(string.substring(to: startIndex!))
        print(contactInfoArray)
        let removeRange = (string.startIndex ..< (range?.upperBound)!)
        
        return recursiveGetValues(string.replacingCharacters(in: removeRange, with: ""), contactInfoArray:newcontactArray)
    }
    
    
}
