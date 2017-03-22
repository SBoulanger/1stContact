//
//  Data.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 10/1/16.
//  Copyright © 2016 Samuel Boulanger. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class DataHub {
    var contact : FCContact!
    var contacts : [FCContact]!
    var phonecontacts : [FCContact] = []
    let defaults = UserDefaults.standard
    var code : String!
    var contactInfo:[String]!
    var sortedAlphArrays: [[FCContact]]!
    var contactStore = CNContactStore()
    var share : [Int] = []
    
    init(){
    
        print("INIT DATAHUB")
        self.contacts = []
        let contactDictionaryData = defaults.data(forKey: "contactDictionary")
        print(contactDictionaryData)
        if contactDictionaryData == nil {
            self.contact = FCContact()
            saveContact()
        } else {
            print("--------------------HEREHEREHERE--------------------")
            let contactDictionary = NSKeyedUnarchiver.unarchiveObject(with: contactDictionaryData!) as! Dictionary<String, AnyObject>
            self.contact = FCContact(dictionary: contactDictionary)
        }
        let contactsDictionaryData = defaults.data(forKey: "contactsDictArray")
        if contactsDictionaryData != nil {
            let contactsDictionary = NSKeyedUnarchiver.unarchiveObject(with: contactsDictionaryData!) as! [Dictionary<String, AnyObject>]
            if contactsDictionary.count == 0 {
                contacts = []
            }
            for i in contactsDictionary {
                self.contacts.append(FCContact(dictionary: i ))
            }
        } else {
            self.contacts = []
            print("ERROR getting contacts")
        }
        self.createAlphArrays(contacts: self.contacts)
        saveContacts()

        self.code = generateString(contact: self.contact,share:self.share)
        self.contactInfo = getContactInfo(info: code)
        if defaults.array(forKey: "share") == nil {
            defaults.set([], forKey: "share")
            self.share = []
        } else {
            self.share = defaults.array(forKey: "share") as! [Int]
        }
        defaults.synchronize()
    }
    func getPhoneContacts() {
        do {
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor])
            try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock: { (cnContact, error) in
                if let thiscontact = FCContact(cnContact: cnContact) {
                    if !self.contacts.contains{ thiscontact.equals(contact: $0) }{
                        self.contacts.append(thiscontact)
                    }
                }
            })
        } catch {
            print("FAILED")
        }
        self.contacts.sort(by: { (a, b) -> Bool in
            if a.firstName.isEmpty {
                return false
            } else if b.firstName.isEmpty {
                return true
            }else {
                return a.firstName.uppercased() < b.firstName.uppercased()
            }
        })
        self.createAlphArrays(contacts: self.contacts)
        
        print("TWITTER:\(getContact().twitter)")
        
    }
    func generateContactInfo(){
        self.code = generateString(contact: self.contact,share:self.share)
        self.contactInfo = getContactInfo(info: code)
    }
    
    func updateContact(contact:FCContact){
        print("updateContact")
        self.contact = contact
        self.contactInfo = getContactInfo(info: code)
        self.code = generateString(contact: self.contact,share:self.share)
        
        let containerview = AppDelegate.getAppDelegate().window?.rootViewController as! ContainerViewController
        let navConview = containerview.rightVc
        let navQRview  = containerview.middleVc
        var arrayViewCon   = navConview?.childViewControllers
        var arrayViewQR    = navQRview?.childViewControllers
        
        let conview    = arrayViewCon?[0] as! ContactsViewController
        let qrview     = arrayViewQR?[0]  as! QRViewController
        
        qrview.generateNewImage()
        conview.refresh()
        
        saveContact()
    }
    func updateContacts(contacts:[FCContact]){
        self.contacts = contacts
        
        self.refreshContacts()
    }
    
    func createAlphArrays(contacts:[FCContact]){
        
        sortedAlphArrays = []
        var prevInitial: Character? = nil
        for tcontact in contacts {
            var initial = tcontact.firstName.uppercased().characters.first
            if initial == nil {
                initial = " "
            }
            if initial != prevInitial {
                sortedAlphArrays.append([])
                prevInitial = initial
            }
            sortedAlphArrays[sortedAlphArrays.endIndex - 1].append(tcontact)
        }
    }
    
    func getSortedAArrays() -> [[FCContact]]{
        return self.sortedAlphArrays
    }
    
    func refreshContacts(){
        
        self.contacts.sort(by: { (a, b) -> Bool in
            if a.firstName.isEmpty {
                return false
            } else if b.firstName.isEmpty {
                return true
            } else {
                return a.firstName.uppercased() < b.firstName.uppercased()
            }
        })
        
        createAlphArrays(contacts: self.contacts)
        
        let containerview = AppDelegate.getAppDelegate().window?.rootViewController as! ContainerViewController
        
        let navConview = containerview.rightVc
        
        var arrayViewCon   = navConview?.childViewControllers
        
        let conview = arrayViewCon?[0] as! ContactsViewController
        
        conview.refresh()
        
        saveContacts()
    }
    
    func getContacts() -> [FCContact] {
        return self.contacts
    }
    
    func getContact() ->FCContact {
        return self.contact
    }
    func addContact(contact: FCContact){
        self.contacts.append(contact)
        self.refreshContacts()
    }
    func deleteContact(contactAt: Int){
        //remove from local instanceup
        var tempContacts = self.contacts
        tempContacts?.remove(at: contactAt)
        //create data from local instance
        self.contacts = tempContacts
        saveContacts()
    }
    
    func saveContact(){
        let dictionaryContact = self.contact.encode()
        let dataContact = NSKeyedArchiver.archivedData(withRootObject: dictionaryContact)
        defaults.set(dataContact, forKey:"contactDictionary")
        defaults.synchronize()
    }
    
    func saveContacts(){
        print("savecontacts")

        var dictionaryContacts = [Dictionary<String, AnyObject>]()
        for i in contacts {
            dictionaryContacts.append(i.encode())
        }
        let dataContacts = NSKeyedArchiver.archivedData(withRootObject: dictionaryContacts)
        defaults.set(dataContacts, forKey: "contactsDictArray")
        
        defaults.synchronize()
        
    }
    
    func createDatafromContactArray(_ contact:[Dictionary<String, AnyObject>]) -> Data {
        let data = NSKeyedArchiver.archivedData(withRootObject: contact)
        return data
    }

    func getContactArrayFromData(_ data:Data) -> [Dictionary<String, AnyObject>] {
        print("getContactArrayFromData(data) entered")
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! [Dictionary<String, AnyObject>]
    }
    
    
    func generateString(contact: FCContact,share:[Int]) -> String {
        var string = "FirstContact/*"
        if share.contains(0){string += contact.firstName}
        string += "/*"
        if share.contains(0){string += contact.lastName}
        string += "/*"
        if share.contains(1){string += contact.phoneNumber}
        string += "/*"
        if share.contains(2){string += contact.email}
        string += "/*"
        if share.contains(3){string += contact.facebook}
        string += "/*"
        if share.contains(4){string += contact.instagram}
        string += "/*"
        if share.contains(5){string += contact.snapchat}
        string += "/*"
        if share.contains(6){string += contact.twitter}
        string += "/*"
        print("return generate string")
        return string
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
    func setShare(nshare: [Int]){
        self.share = nshare
        defaults.set(self.share, forKey: "share")
    }
    func retrieveContacts(completion: (_ success: Bool, _ contacts: [FCContact]?) -> Void) {
        do {
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor])
            try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock: { (cnContact, error) in
                if let contact = FCContact(cnContact: cnContact) {
                    self.contacts.append(contact)
                }
            })
            completion(true, contacts)
        } catch {
            completion(false, nil)
        }
    }

    
}
extension String {
    var isAlphanumeric: Bool {
        for chr in self.characters {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
                return false
            }
        }
        return true
    }
}

