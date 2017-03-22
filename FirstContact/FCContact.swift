//
//  File.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 8/24/16.
//  Copyright © 2016 Samuel Boulanger. All rights reserved.
//

import Foundation
import UIKit
import Contacts

//first last phone emial insta snap facebook

public struct FCContact {
    var firstName : String! = ""
    var lastName : String! = ""
    var phoneNumber : String! = ""
    var snapchat : String! = ""
    var instagram : String! = ""
    var facebook: String! = ""
    var email : String! = ""
    var twitter : String! = ""
    var share: [Int]! = []
    var me : Bool! = false
    
    init(){
        self.firstName = ""
        self.lastName = ""
        self.phoneNumber = ""
        self.snapchat = ""
        self.instagram = ""
        self.email = ""
        self.facebook = ""
        self.twitter = ""
    }
    
    //Decode
    public init(dictionary: Dictionary<String, AnyObject>){
        if ((dictionary["firstName"] as? String) != nil) {
            firstName = dictionary["firstName"] as? String
        } else {
            firstName = ""
        }
        if ((dictionary["lastName"] as? String) != nil) {
            lastName = dictionary["lastName"] as? String
        } else {
            lastName = ""
        }
        if ((dictionary["phoneNumber"] as? String) != nil) {
            phoneNumber = dictionary["phoneNumber"] as? String
        } else {
            phoneNumber = ""
        }
        if ((dictionary["snapchat"] as? String) != nil) {
            snapchat = dictionary["snapchat"] as? String
        } else {
            snapchat = ""
        }
        if ((dictionary["instagram"] as? String) != nil) {
            instagram = dictionary["instagram"] as? String
        } else {
            instagram = ""
        }
        if ((dictionary["facebook"] as? String) != nil) {
            facebook = dictionary["facebook"] as? String
        } else {
            facebook = ""
        }
        if ((dictionary["email"] as? String) != nil) {
            email = dictionary["email"] as? String
        } else {
            email = ""
        }
        if ((dictionary["twitter"] as? String) != nil) {
            twitter = dictionary["twitter"] as? String
        } else {
            twitter = ""
        }
        if ((dictionary["me"] as? Bool) != nil) {
            me = dictionary["me"] as? Bool
        } else {
            me = false
        }
    }
    
    //Encode
    public func encode() -> Dictionary<String, AnyObject> {
        var dictionary : Dictionary = Dictionary<String, AnyObject>()
        dictionary["firstName"] = firstName as AnyObject?
        dictionary["lastName"] = lastName as AnyObject?
        dictionary["phoneNumber"] = phoneNumber as AnyObject?
        dictionary["snapchat"] = snapchat as AnyObject?
        dictionary["instagram"] = instagram as AnyObject?
        dictionary["facebook"] = facebook as AnyObject?
        dictionary["email"] = email as AnyObject?
        dictionary["twitter"] = twitter as AnyObject?
        dictionary["me"] = me as AnyObject?
        return dictionary
    }
    
    init(contact:CNContact){
        firstName = contact.givenName
        lastName = contact.familyName
        phoneNumber = contact.phoneNumbers[0].label
    }
    init(first:String,last:String,phoneNumber:String,email:String,snapchat:String,instagram:String,facebook:String,twitter:String){
        firstName = first
        lastName = last
        self.phoneNumber = phoneNumber
        self.email = email
        self.snapchat = snapchat
        self.instagram = instagram
        self.facebook = facebook
        self.twitter = twitter
    }
    func getField(fieldIndex:Int) -> String {
        switch fieldIndex {
        case 0: return self.firstName
        case 1: return self.lastName
        case 2: return self.phoneNumber
        case 3: return self.email
        case 4: return self.facebook
        case 5: return self.instagram
        case 6: return self.snapchat
        case 7: return self.twitter
        default:
            return ""
        }
    }
    func equals(contact:FCContact) -> Bool{
        if self.firstName != contact.firstName {
            return false
        }
        if self.lastName != contact.lastName {
            return false
        }
        if self.phoneNumber != contact.phoneNumber {
            return false
        }
        return true
    }
    init?(cnContact: CNContact) {
        // name
        if cnContact.isKeyAvailable(CNContactGivenNameKey){
            self.firstName = cnContact.givenName
        }
        if cnContact.isKeyAvailable(CNContactFamilyNameKey){
            self.lastName = cnContact.familyName
        }
        
        // email
        /*if cnContact.isKeyAvailable(CNContactEmailAddressesKey) {
            self.email = cnContact.emailAddresses[0].value as String
        }*/
        
        // phone
        if cnContact.isKeyAvailable(CNContactPhoneNumbersKey) {
            if cnContact.phoneNumbers.count > 0 {
                let phone = (cnContact.phoneNumbers.first?.value)! as CNPhoneNumber
                self.phoneNumber = phone.stringValue as String
            }
        }
    }
}
