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

public struct FCContact: Equatable, Hashable {
    var id : Int! = 0
    public var hashValue: Int { get { return id.hashValue } }
    var firstName : String! = ""
    var lastName : String! = ""
    var phoneNumber : String! = ""
    var snapchat : String! = ""
    var instagram : String! = ""
    var facebook: String! = ""
    var email : String! = ""
    //var twitter : String! = ""
    var share: [Int]! = []
    var me : Bool! = false
    
    init(){
        self.id = UUID().hashValue
        self.firstName = ""
        self.lastName = ""
        self.phoneNumber = ""
        self.snapchat = ""
        self.instagram = ""
        self.email = ""
        self.facebook = ""
        //self.twitter = ""
        
    }
    
    //Decode
    public init(dictionary: Dictionary<String, AnyObject>){
        if ((dictionary["id"] as? Int) != nil) {
           self.id = dictionary["id"] as? Int
        } else {
            print("NEW ID")
            self.id = UUID().hashValue
        }
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
        if ((dictionary["facebook"] as? [String:Any]) != nil) {
            facebook = dictionary["facebook"] as? String
        } else {
            facebook = ""
        }
        if ((dictionary["email"] as? String) != nil) {
            email = dictionary["email"] as? String
        } else {
            email = ""
        }
        /*
        if ((dictionary["twitter"] as? String) != nil) {
            twitter = dictionary["twitter"] as? String
        } else {
            twitter = ""
        }
         */
        if ((dictionary["me"] as? Bool) != nil) {
            me = dictionary["me"] as? Bool
        } else {
            me = false
        }
    }
    
    public init(data: Data){
        encodeJSON(data: data)
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
        dictionary["me"] = me as AnyObject?
        dictionary["id"] = id as AnyObject?
        return dictionary
    }
    public mutating func encodeJSON(data: Data){
        print("FCContact: encodeJSON(data: \(data))")
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let dictionary = json as? [String: Any] {
            for (key, value) in dictionary {
                print("key \(key) value \(value)")
                setValue(key: key, value: value)
            }
        }
        
    }
    public mutating func encodeShareJSON(data: Data, share:[Int]){
        print("FCContact: encodeShareJSON(data: share:\(share)")
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let dictionary = json as? [String: Any] {
            for (key, value) in dictionary {
                for i in share {
                    if key == getKey(index: i){
                        print("key \(key) value \(value)")
                        setValue(key: key, value: value)
                    }
                }
            }
        }
    }
    public func getDefaultJSONData() -> Data {
        
        let jsonObject : [String: Any] = self.getDefaultJSON()
        print("Default .json is valid: \(JSONSerialization.isValidJSONObject(jsonObject))")
        let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
        return data!
    }
    public func getDefaultJSON() -> [String: Any] {
        let jsonObject : [String: Any] = [
            
            "firstName": self.firstName,
            "lastName" : self.lastName,
            "phoneNumber": self.phoneNumber,
            "email":self.email,
            "snapchat":self.snapchat,
            "instagram":self.instagram,
            "facebook":self.facebook,
            "me":self.me,
            "id":self.id
            
        ]
        return jsonObject
    }
    
    init(contact:CNContact){
        id = UUID().hashValue
        firstName = contact.givenName
        lastName = contact.familyName
        phoneNumber = contact.phoneNumbers[0].label
    }
    init(first:String,last:String,phoneNumber:String,email:String,snapchat:String,instagram:String,facebook:String){
        self.id = UUID().hashValue
        firstName = first
        lastName = last
        self.phoneNumber = phoneNumber
        self.email = email
        self.snapchat = snapchat
        self.instagram = instagram
        self.facebook = facebook
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
        //case 7: return self.twitter
        default:
            print("default")
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
    mutating func setValue(key:String,value:Any){
        switch key {
        case "firstName":
            self.firstName = value as! String
        case "lastName":
            self.lastName = value as! String
        case "phoneNumber":
            self.phoneNumber = value as! String
        case "email":
            self.email = value as! String
        case "facebook":
            self.facebook = value as! String
        case "instagram":
            self.instagram = value as! String
        case "snapchat":
            self.snapchat = value as! String
        case "id":
            self.id = value as! Int
        case "me":
            self.me = value as! Bool
        default:
            print("default")
        }
    }
    func getKey(index:Int) -> String {
        switch index {
        case 0:
            return "firstName"
        case 1:
            return "lastName"
        case 2:
            return "phoneNumber"
        case 3:
            return "email"
        case 4:
            return "facebook"
        case 5:
            return "instagram"
        case 6:
            return "snapchat"
        case 7:
            return "me"
        default:
            return "nil"
        }
    }
    init?(cnContact: CNContact) {
        self.id = UUID().hashValue
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
    public static func ==(lhs: FCContact, rhs: FCContact) -> Bool{
        print(lhs.id)
        print(rhs.id)
        return lhs.id == rhs.id
    }
}

