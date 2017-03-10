//
//  ContactViewController.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 9/4/16.
//  Copyright © 2016 Samuel Boulanger. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import TwitterKit
import Fabric
import MMCardView
/*
 First name
 Last name
 Company
 Phone
 Email
 Insta
 Snapchat
 Facebook
 Address
 Twitter
 
*/
class ContactViewController: UIViewController, UITextFieldDelegate {
    
    
    
    //@IBOutlet weak var scrollView: UIScrollView!
    var string = ""
    
    @IBOutlet weak var firstNameTF: UITextField!
    
    @IBOutlet weak var lastNameTF: UITextField!
    
    @IBOutlet weak var phoneNumberTF: UITextField!
    
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var facebookTF: UITextField!
    
    @IBOutlet weak var instagramTF: UITextField!
    
    @IBOutlet weak var snapchatTF: UITextField!
    
    @IBOutlet weak var twitterTF: UITextField!
    
    @IBOutlet weak var companyTF: UITextField!
    
    
    @IBOutlet weak var firstNameB: UIButton!
    var fnFilled = false
    
    @IBOutlet weak var lastNameB: UIButton!
    var lnFilled = false
    
    @IBOutlet weak var phoneNumberB: UIButton!
    var pnFilled = false
    
    @IBOutlet weak var emailB: UIButton!
    var eFilled = false
    
    @IBOutlet weak var facebookB: UIButton!
    var fbFilled = false
    
    @IBOutlet weak var instagramB: UIButton!
    var igFilled = false
    
    @IBOutlet weak var snapchatB: UIButton!
    var scFilled = false
    
    @IBOutlet weak var twitterB: UIButton!
    var twFilled = false
    
    @IBOutlet weak var containerView: UIView!
    
    
    var dictionaryIndex: Int!
    
    var labelTimer = Timer()//.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(fillLabel(sender:)), userInfo: nil, repeats: true)
    
    var  textFieldArr = [UITextField]()
    
    var categories = ["firstname","lastname","company","phone number","email","instagram","snapchat","facebook","twitter"]
    var buttonarray: [UIView]!
    var textfieldarray: [UITextField]!
    var filledarray: [Bool]!
    var contact: FCContact!
    var globalTwitter: Twitter!
    /*init(contact:CNContact)
    {
        print("hello")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }*/
    //x381 y-5
    
    
    var dataHub: DataHub!
    var globalSession: TWTRSession!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if contact.me == true {
            if((FBSDKAccessToken.current()) != nil){
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id"]).start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil){
                        var result1 = result as! Dictionary<String,String>
                        if (self.contact.facebook != result1["id"]){
                            self.contact.facebook = result1["id"]
                            self.dataHub.saveContact()
                        }
                    }
                })
            } else {
                print("NOPE NOPE NOPE")
            }
        }
    }
    @IBOutlet weak var card: CardView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("viewdidload")
        
        print("self.frame = \(self.view.frame.width)")
        print("container = \(self.containerView.frame.width)")
        print("textfield = \(self.facebookTF.frame.width)")
        
        filledarray = [fnFilled,lnFilled,pnFilled,eFilled,fbFilled,igFilled,scFilled,twFilled]
        dataHub = AppDelegate.getAppDelegate().dataHub
        
        if contact.me == true {
            
            let frame = CGRect(x: self.view.frame.origin.x+15, y: CGFloat(292), width: self.view.bounds.width-30, height: self.firstNameTF.frame.height)
            let loginButton = FBSDKLoginButton()
            
            // Optional: Place the button in the center of your view.
            loginButton.frame = frame
            print("\(loginButton.titleLabel?.font)")
            //loginButton.center = CGPoint(x: self.view.bounds.width-100, y: CGFloat(305))
            self.containerView.addSubview(loginButton)
            self.facebookB.isHidden = true
            self.facebookTF.isHidden = true
            let accesstocken = FBSDKAccessToken.current()
            if((FBSDKAccessToken.current()) != nil){
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id"]).start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil){
                        var result1 = result as! Dictionary<String,String>
                        self.contact.facebook = result1["id"]
                        self.dataHub.saveContact()
                    }
                })
            } else {
                print("NOT")
            }
        
            self.twitterB.isHidden = true
            self.twitterTF.isHidden = true
            
            
            let twitter = Twitter.sharedInstance()
            globalTwitter = twitter
            if twitter.sessionStore.session() == nil {
                let logInButton = TWTRLogInButton(logInCompletion: { session, error in
                    if (session != nil) {
                        print("signed in as \(session?.userName)")
                        self.globalSession = session
                        self.dataHub.contact.twitter = session?.userName
                        self.dataHub.saveContact()
                    } else {
                        print("error: \(error?.localizedDescription)");
                    }
                })
                var frame = CGRect(x: self.view.frame.origin.x+15, y: CGFloat(479), width: self.view.bounds.width-30, height: self.firstNameTF.frame.height)
                //logInButton.center = CGPoint(x: self.view.bounds.width-100, y: CGFloat(479))
                logInButton.frame = frame
                logInButton.addTarget(self, action: #selector(logintwitter(sender:)), for: UIControlEvents.touchUpInside)
                loginButton.layer.cornerRadius = 5.0
                self.containerView.addSubview(logInButton)
                //logInButton.setTitle("Logout", for: .normal)
            }
            else {
                print("Logged IN:")
                self.globalSession = twitter.sessionStore.session() as! TWTRSession!
                let logInButton = TWTRLogInButton()
                let logOutButton = UIButton()
                logOutButton.frame = loginButton.frame
                logOutButton.backgroundColor = logInButton.backgroundColor
                //logOutButton.setBackgroundImage(logInButton.backgroundImage(for: .normal), for: .normal)
                logOutButton.setTitle(" Log out", for: .normal)
                //logOutButton.titleLabel?.font = UIFont(name: "System", size: 14)
                logOutButton.addTarget(self, action: #selector(logouttwitter(sender:)), for: UIControlEvents.touchUpInside)
                let frame = CGRect(x: self.view.frame.origin.x + 15, y: CGFloat(479), width: self.view.frame.width-30, height: self.firstNameTF.frame.height)
                //logOutButton.center = CGPoint(x: self.view.bounds.width-100, y: CGFloat(479))
                logOutButton.frame = frame
                logOutButton.setImage(UIImage(named:"twtr-icn-logo-white@2x.png"), for: .normal)
                logOutButton.layer.cornerRadius = 5.0
                self.containerView.addSubview(logOutButton)
                
                print("Twitter:\(dataHub.getContact().twitter)")
                
                
                
                
                

            }
        }
        
        
        firstNameTF.addTarget(self, action: #selector(textFieldEmptyChange(sender:)), for: UIControlEvents.editingChanged)
        lastNameTF.addTarget(self, action: #selector(textFieldEmptyChange(sender:)), for: UIControlEvents.editingChanged)
        phoneNumberTF.addTarget(self, action: #selector(textFieldEmptyChange(sender:)), for: UIControlEvents.editingChanged)
        emailTF.addTarget(self, action: #selector(textFieldEmptyChange(sender:)), for: UIControlEvents.editingChanged)
        instagramTF.addTarget(self, action: #selector(textFieldEmptyChange(sender:)), for: UIControlEvents.editingChanged)
        snapchatTF.addTarget(self, action: #selector(textFieldEmptyChange(sender:)), for: UIControlEvents.editingChanged)
        twitterTF.addTarget(self, action: #selector(textFieldEmptyChange(sender:)), for: UIControlEvents.editingChanged)

        
        textfieldarray = [firstNameTF,lastNameTF,phoneNumberTF,emailTF,facebookTF,instagramTF,snapchatTF,twitterTF]
        
        buttonarray = [firstNameB,lastNameB,phoneNumberB,emailB,facebookB,instagramB,snapchatB,twitterB]
        
        
        let touch: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ContactViewController.closeKeyboard))
        view.addGestureRecognizer(touch)
        var i = 0
        
        for labelview in buttonarray {
            var button = labelview as! UIButton
            labelview.layer.borderColor = UIColor.green.cgColor
            if labelview == snapchatB {
                if (contact.snapchat == snapchatTF.text){
                    button.setTitle("Go", for: UIControlState.normal)
                } else {
                    button.setTitle("Save", for: UIControlState.normal)
                }
            }
            else if labelview == instagramB {
                if (contact.instagram == instagramTF.text){
                    button.setTitle("Go", for: UIControlState.normal)
                } else {
                    button.setTitle("Save", for: UIControlState.normal)
                }
            }
            else if labelview == twitterB {
                if (contact.twitter == twitterTF.text){
                    button.setTitle("Go", for: UIControlState.normal)
                } else {
                    button.setTitle("Save", for: UIControlState.normal)
                }
            }
            else if labelview == facebookB {
                labelview.layer.borderColor = UIColor(colorLiteralRed: 45/255, green: 68/255, blue: 134/255, alpha: 1.0).cgColor
            }
            button.setTitleColor(UIColor.white, for: UIControlState.normal)
            labelview.clipsToBounds = true
            labelview.layer.cornerRadius = 0.5 * firstNameB.layer.bounds.size.width
            labelview.backgroundColor = UIColor.white
            labelview.layer.borderWidth = 2
        }
        
        
        for myTextField in textfieldarray {
            let bottomLine = CALayer()
            bottomLine.frame = CGRect(x: 0.0, y: myTextField.frame.height - 1, width: myTextField.frame.width, height: 1.0)
            let grey = UIColor(white: 0.890, alpha: 1.0)
            bottomLine.backgroundColor = grey.cgColor
            myTextField.borderStyle = UITextBorderStyle.none
            myTextField.layer.addSublayer(bottomLine)
            myTextField.delegate = self
            myTextField.tag = i
            i = i + 1
        }
        
        firstNameTF.text = contact.firstName
        lastNameTF.text = contact.lastName
        

        for i in 0...textfieldarray.count-1 {
            textfieldarray[i].text = contact.getField(fieldIndex: i)
            if textfieldarray[i].text == "" { filledarray[i] = false }
            else { filledarray[i] = true }
            textFieldEmptyChange(sender: textfieldarray[i])
        }
    }
    
    func logouttwitter(sender: TWTRLogInButton){
        print("Twitter:\(dataHub.getContact().twitter)")
        Twitter.sharedInstance().sessionStore.logOutUserID(self.globalSession.userID)
        self.dataHub.contact.twitter = ""
        dataHub.saveContact()
        let twitter = Twitter.sharedInstance()
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                
                print("signed in as \(session?.userName)")
                self.globalSession = session
                self.dataHub.contact.twitter = session?.userName
                self.dataHub.saveContact()
            } else {
                print("error: \(error?.localizedDescription)");
            }
        })
        sender.removeFromSuperview()
        logInButton.frame = sender.frame
        logInButton.addTarget(self, action: #selector(logintwitter(sender:)), for: UIControlEvents.touchUpInside)
        self.containerView.addSubview(logInButton)

        print("Twitter:\(dataHub.getContact().twitter)")
    }
    func logintwitter(sender: TWTRLogInButton){
        let logOutButton = UIButton()
        logOutButton.frame = sender.frame
        logOutButton.backgroundColor = sender.backgroundColor
        logOutButton.setTitle(" Log out", for: .normal)
        logOutButton.addTarget(self, action: #selector(logouttwitter(sender:)), for: UIControlEvents.touchUpInside)
        //logOutButton.center = CGPoint(x: self.view.bounds.width-100, y: CGFloat(479))
        logOutButton.setImage(UIImage(named:"twtr-icn-logo-white@2x.png"), for: .normal)
        self.containerView.addSubview(logOutButton)
        sender.removeFromSuperview()
        print("Twitter:\(dataHub.getContact().twitter)")
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
    
    func closeKeyboard(){
        view.endEditing(true)
    }
    
    func textFieldEmptyChange(sender:UITextField!){
        let text = sender.text as String!
        let fieldIndex = textfieldarray.index(of: sender)
        print(filledarray[fieldIndex!])
        print(text)
        if text == "" {
            startFillTimer(label: buttonarray[fieldIndex!], isFilled: false)
            if filledarray[fieldIndex!] == true {
                filledarray[fieldIndex!] = false
            }
        } else {
            startFillTimer(label: buttonarray[fieldIndex!], isFilled: true)
            if filledarray[fieldIndex!] == false {
                filledarray[fieldIndex!] = true
            }
        }
    }

    func fillLabel(sender:Timer!){
        var label = sender.userInfo as! UIView
        label.layer.borderWidth += 0.1
        if label.layer.borderWidth >= 15 {
            sender.invalidate()
        }
    }
    
    func unfillLabel(sender:Timer!){
        var label = sender.userInfo as! UIView
        label.layer.borderWidth -= 0.1
        if label.layer.borderWidth <= 2 {
            sender.invalidate()
        }
    }
    func startFillTimer(label:UIView,isFilled:Bool){
        if isFilled == true {
            var timer = Timer.scheduledTimer(timeInterval: 0.002, target: self, selector: #selector(fillLabel(sender:)), userInfo: label, repeats: true)
        } else {
            var timer = Timer.scheduledTimer(timeInterval: 0.002, target: self, selector: #selector(unfillLabel(sender:)), userInfo: label, repeats: true)
        }
    }
    
    @IBAction func buttonPress(_ sender: AnyObject) {
        var button = sender as! UIButton
        var index = buttonarray.index(of: button)!
        print(index)
        var textField = textfieldarray[index]
        var text = textField.text
        switch index {
        case 0:
            contact.firstName = text
            break
        case 1:
            contact.lastName = text
            break
        case 2:
            contact.phoneNumber = text
            break
        case 3:
            contact.email = text
            break
        case 4:
            var fbHooks = "fb://profile/\(contact.facebook!)"
            var fbUrl = URL(string: fbHooks)
            if UIApplication.shared.canOpenURL(fbUrl!)
            {
                UIApplication.shared.openURL(fbUrl!)
                
            } else {
                //redirect to safari because the user doesn't have Instagram
                UIApplication.shared.openURL(URL(string: "http://facebook.com/")!)
            }
            break
        case 5:
            if text == contact.instagram {
                var instagramHooks = "instagram://user?username=\(contact.instagram!)"
                var instagramUrl = URL(string: instagramHooks)
                if UIApplication.shared.canOpenURL(instagramUrl!)
                {
                    UIApplication.shared.openURL(instagramUrl!)
                    
                } else {
                    //redirect to safari because the user doesn't have Instagram
                    UIApplication.shared.openURL(URL(string: "http://instagram.com/")!)
                }
            }
            else {
                contact.instagram = text
            }
            break
        case 6:
            if text == contact.snapchat {
                var snapHooks = "snapchat://add/\(contact.snapchat!)"
                var snapchatUrl = URL(string: snapHooks)
                if UIApplication.shared.canOpenURL(snapchatUrl!)
                {
                    UIApplication.shared.openURL(snapchatUrl!)
                    
                } else {
                    //redirect to safari because the user doesn't have Snapchat
                    UIApplication.shared.openURL(URL(string: "http://snapchat.com/")!)
                }
            } else {
                contact.snapchat = text
            }
            break
        case 7:
            if text == contact.twitter {
                var twitterHooks = "twitter://user?screen_name=\(contact.twitter!)"
                var twitterUrl = URL(string: twitterHooks)
                if UIApplication.shared.canOpenURL(twitterUrl!)
                {
                    UIApplication.shared.openURL(twitterUrl!)
                    
                } else {
                    //redirect to safari because the user doesn't have Instagram
                    UIApplication.shared.openURL(URL(string: "http://twitter.com/")!)
                }
            }
            else {
                contact.twitter = text
            }
            break
        default:
            break
        }
        if contact.me == true {
            dataHub.updateContact(contact: contact)
        }else{
            var tempcontacts = dataHub.getContacts()
            print(dictionaryIndex)
            tempcontacts[dictionaryIndex] = contact
            dataHub.updateContacts(contacts: tempcontacts)
        }
    }
    func createDatafromContactArray(_ contact:[Dictionary<String, AnyObject>]) -> Data {
        let data = NSKeyedArchiver.archivedData(withRootObject: contact)
        return data
    }
}

    

