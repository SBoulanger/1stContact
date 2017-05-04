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
import AWSMobileHubHelper
import FBSDKLoginKit
//import CryptoSwift

import ObjectiveC

class DataHub {
    var contact : FCContact!
    var contacts : [FCContact] = []
    var localContacts : [FCContact] = []
    var localContact : FCContact!
    var phonecontacts : [FCContact] = []
    let defaults = UserDefaults.standard
    var code : String!
    var contactInfo:[String]!
    var sortedAlphArrays: [[FCContact]]!
    var contactStore = CNContactStore()
    var share : [Int] = []

    var contactsVC : ContactsViewController!
    var qrVC : QRViewController!

    
    fileprivate var prefix: String!
    fileprivate var manager: AWSUserFileManager!
    fileprivate var contents: [AWSContent]?
    fileprivate var didLoadAllContents: Bool!
    fileprivate var marker: String?
    
    fileprivate let CONTACT_FILE_DIRECTORY = "protected"
    fileprivate let CONTACTS_FILE_DIRECTORY = "private"
    
    init(){
        print("DataHub: INITIALIZATION")
        self.contact = FCContact()
        self.contact.me = true
        self.contacts = []
        
        setUpViews()
        
        //Set up AWS Settings
        setUpAWS()
        
        if (AWSSignInManager.sharedInstance().isLoggedIn){
            self.code = generateRemoteString(share: self.share)
        } else {
            self.code = generateDirectString(contact: self.contact,share:self.share)
        }
        self.contactInfo = getContactInfo(info: code)
        
        if defaults.array(forKey: "share") == nil {
            defaults.set([], forKey: "share")
            self.share = []
        } else {
            self.share = defaults.array(forKey: "share") as! [Int]
        }
        self.createAlphArrays(contacts: self.contacts)
    }
    func setUpViews(){
        let containerview = AppDelegate.getAppDelegate().window?.rootViewController as! ContainerViewController
        let navConview = containerview.rightVc
        let navQRview  = containerview.middleVc
        var arrayViewCon   = navConview?.childViewControllers
        var arrayViewQR    = navQRview?.childViewControllers
        
        self.contactsVC    = arrayViewCon?[0] as! ContactsViewController
        self.qrVC     = arrayViewQR?[0]  as! QRViewController
    }

    func syncData(){
        print("DataHub: syncData()")
        print("localContacts:\(localContacts)")
        print("contacts:\(contacts)")
        self.contacts = localContacts + contacts
        var alreadyThere = Set<FCContact>()
        let uniqueContacts = contacts.flatMap { (tcontact) -> FCContact? in
            guard !alreadyThere.contains(tcontact) else { return nil }
            alreadyThere.insert(tcontact)
            return tcontact
        }
        self.updateContacts(contacts: uniqueContacts)
    }
    func setUpAWS(){
        print("DataHub: setUpAWS()")
                
        didLoadAllContents = false
        manager = AWSUserFileManager.defaultUserFileManager()
        
        if (AWSSignInManager.sharedInstance().isLoggedIn){
            print("DataHub: AWS is logged in")
            let userId = AWSIdentityManager.default().identityId!
            prefix = "\(UserFilesPrivateDirectoryName)/\(userId)/"
            print("PREFIX "+prefix)
            marker = nil
            loadAWSContent()
        } else {
            getLocalData()
        }
    }
    func getLocalData(){
        let contactDictionaryData = defaults.data(forKey: "contactDictionary")
        if contactDictionaryData == nil {
            self.localContact = FCContact()
        } else {
            let contactDictionary = NSKeyedUnarchiver.unarchiveObject(with: contactDictionaryData!) as! Dictionary<String, AnyObject>
            self.localContact = FCContact(dictionary: contactDictionary)
        }
        let contactsDictionaryData = defaults.data(forKey: "contactsDictArray")
        if contactsDictionaryData != nil {
            let contactsDictionary = NSKeyedUnarchiver.unarchiveObject(with: contactsDictionaryData!) as! [Dictionary<String, AnyObject>]
            if contactsDictionary.count == 0 {
                self.localContacts = []
            }
            for i in contactsDictionary {
                self.localContacts.append(FCContact(dictionary: i ))
            }
        } else {
            self.localContacts = []
        }
        if (!AWSSignInManager.sharedInstance().isLoggedIn){
            self.contact = localContact
            self.contacts = localContacts
        }
        defaults.synchronize()
    }
    func refreshQRImage(){
        self.qrVC.generateNewImage()
    }
    
    public func wipeData(){
        self.contact = FCContact()
        self.contacts = []
        removeFbData()
        saveContact()
        refreshContacts()
    }
    
    public func refreshData(){
        self.contact = FCContact()
        self.contacts = []
        setUpAWS()
    }
    
    fileprivate func refreshContents() {
        marker = nil
        loadAWSContent()
    }
    
    fileprivate func loadAWSContent() {
        print("DataHub: loadAWSContent()")
        manager.listAvailableContents(withPrefix: prefix, marker: marker, completionHandler: {[weak self] (contents: [AWSContent]?, nextMarker: String?, error: Error?) in
            guard let strongSelf = self else { return }
            if let error = error {
                self?.qrVC.stopSpinning()
                print("Failed to load the list of contents. \(error)")
            }
            if let contents = contents, contents.count > 0 {
                strongSelf.contents = contents
                print("DataHub: --- Contents = \(contents)")
                if let nextMarker = nextMarker, !nextMarker.isEmpty {
                    strongSelf.didLoadAllContents = false
                } else {
                    strongSelf.didLoadAllContents = true
                }
                strongSelf.marker = nextMarker
            } else {
                
                strongSelf.saveContact()
                strongSelf.refreshContacts()
                print("DataHub: Contents is empty")
            }
            strongSelf.downloadContents()
        })
    }
    
    func downloadContents(){
        print("DataHub: downloadContents()")
        self.contents?.forEach({ (content: AWSContent) in
            print("Content: \(content)")
            print("key - \(content.key)")
            print("cached = \(content.isCached)")
            if !content.isDirectory {
                if (content.key.range(of: ".json") != nil){
                    print("content is .json")
                    if !content.isCached {
                        downloadContent(content, pinOnCompletion: false)
                    } else {
                        content.removeLocal()
                        downloadContent(content, pinOnCompletion: false)
                        //downloadContactContacts(content: content, data: content.cachedData)
                    }
                }
            }
        })
    }
    
    func downloadContactContacts(content: AWSContent, data: Data){
        print("downloadContactContacts(content: AWSContent, data: Data")
        if (content.key.range(of: "contact.json") != nil){
            self.downloadContact(data: data)
        } else if (content.key.range(of: "contacts.json") != nil){
            self.downloadContacts(data: data)
        }
    }
    
    func downloadContact(data: Data){
        print("downloadContact(data: Data)")
        self.contact.encodeJSON(data: data)
        self.contact.me = true
        saveContact()
    }
    func downloadContacts(data: Data){
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        print("DataHub: json of incoming contacts: \(json)")
        if let contacts = json as? [[String: Any]] {
            //print("DataHub: contacts downloaded = \(contacts)")
            for contact in contacts {
                var fc = FCContact()
                for (key, value) in contact {
                    fc.setValue(key: key, value: value)
                }
                self.contacts.append(fc)
            }
        }
        self.refreshContacts()
    }
    
    fileprivate func downloadContent(_ content: AWSContent, pinOnCompletion: Bool) {
        print("DataHub: downloadContent(content: \(content), pinOnCompletion: \(pinOnCompletion)")
        content.download(with: .ifNewerExists, pinOnCompletion: pinOnCompletion, progressBlock: {[weak self] (content: AWSContent, progress: Progress) in
            guard let strongSelf = self else { return }
            }, completionHandler: {[weak self] (content: AWSContent?, data: Data?, error: Error?) in
            guard let strongSelf = self else { return }
                if (content != nil && data != nil){
                    strongSelf.downloadContactContacts(content: content!, data: data!)
                } else {
                    print("FAILLLL NIL FOUND IN DATA OR CONTENT")
                }
            if let error = error {
                print("Failed to download a content from a server. \(error)")
                //AppDelegate.getAppDelegate().showMessage("Failed up download contact info")
            }
            strongSelf.getLocalData()
            strongSelf.syncData()
        })
    }
    fileprivate func uploadWithData(data: NSData, forKey key: String, prefix: String) {
        let manager = AWSUserFileManager.defaultUserFileManager()
        let localContent = manager.localContent(with: data as Data, key: prefix + key)
        print(prefix+key)
        localContent.uploadWithPin(
            onCompletion: false,
            progressBlock: {[weak self](content: AWSLocalContent, progress: Progress) -> Void in
                guard let strongSelf = self else { return }
                /* Show progress in UI. */
            },
            completionHandler: {[weak self](content: AWSLocalContent?, error: Error?) -> Void in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("Failed to upload an object. error = \(error)")
                    
                    strongSelf.qrVC.stopSpinning()
                } else {
                    print("Object upload complete. error = \(error)")
                    strongSelf.qrVC.stopSpinning()
                }
        })
    }
    public func getDefaultContactsJSONData() -> Data {
        let jsonObject = self.getDefaultContactsJSON()
        print(jsonObject)
        print("Default .json is valid: \(JSONSerialization.isValidJSONObject(jsonObject))")
        let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
        return data!
    }
    public func getDefaultContactsJSON() -> [[String: Any]] {
        var contactsJson : [[String: Any]] = []
        print("Contacts \(self.contacts)")
        for icontact in self.contacts {
            print("Contact \(icontact)")
            contactsJson.append(icontact.getDefaultJSON())
        }
        return contactsJson
    }
    func uploadContacts(){
        uploadWithData(data: getDefaultContactsJSONData() as NSData, forKey: "contacts.json", prefix: prefix)
    }
    func uploadContact(){
        print("uploadContact()")
        uploadWithData(data: self.contact.getDefaultJSONData() as NSData, forKey: "contact.json", prefix: prefix)
        let userId = AWSIdentityManager.default().identityId!
        uploadWithData(data: self.contact.getDefaultJSONData() as NSData, forKey: "contact.json", prefix:"\(CONTACT_FILE_DIRECTORY)/\(userId)/")
    }
    /*
    func uploadTestContacts(){
        let f = FCContact(first: "Maya", last: "Eastman", phoneNumber: "8055555555", email: "mayaeastman@gmail.com", snapchat: "mayaeast", instagram: "mayaeast", facebook: "facebookEastman")
        self.contacts = [FCContact(),f]
        print("uploadTestContacts: \(self.contacts)")
        uploadContacts()
    }
    func uploadTestContact(){
        let f = FCContact(first: "Samuel", last: "Boulanger", phoneNumber: "8054555360", email: "samuelrdboulanger@gmail.com", snapchat: "sboulanger", instagram: "sboulanger", facebook: "facebook")
        self.contact = f
        uploadContact()
    }
    */
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
        
    }
    func generateContactInfo(){
        if (AWSSignInManager.sharedInstance().isLoggedIn){
            self.code = generateRemoteString(share: self.share)
        } else {
            self.code = generateDirectString(contact: self.contact,share:self.share)
        }
        self.contactInfo = getContactInfo(info: code)
    }
    
    func updateContact(contact:FCContact){
        print("DataHub: updateContact(contact: FCContact)")
        self.contact = contact
        self.contactInfo = getContactInfo(info: code)
        if (AWSSignInManager.sharedInstance().isLoggedIn){
            self.code = generateRemoteString(share: self.share)
        } else {
            self.code = generateDirectString(contact: self.contact,share:self.share)
        }
        
        self.qrVC.generateNewImage()
        self.contactsVC.refresh()
        
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
        tempContacts.remove(at: contactAt)
        //create data from local instance
        self.contacts = tempContacts
        saveContacts()
    }
    
    func saveContact(){
        print("DataHub: saveContact()")
        if (AWSSignInManager.sharedInstance().isLoggedIn){
            uploadContact()
        }
        let dictionaryContact = self.contact.encode()
        let dataContact = NSKeyedArchiver.archivedData(withRootObject: dictionaryContact)
        defaults.set(dataContact, forKey:"contactDictionary")
        defaults.synchronize()
    }
    
    func saveContacts(){
        print("savecontacts")
        
        if (AWSSignInManager.sharedInstance().isLoggedIn){
            uploadContacts()
        }

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
    
    
    func generateDirectString(contact: FCContact,share:[Int]) -> String {
        print("generateDirectString(contact,share)")
        var string = "FirstContact/*"
        string += "direct/*"
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
        if share.contains(6){string += contact.linkedin}
        string += "/*"
        
        return string
    }
    func generateRemoteString(share: [Int]) -> String {
        print("DataHub: generateRemoteString(share)")
        var string = "FirstContact/*"
        string += "remote/*"
        for i in share {
            string += "\(i),"
        }
        if share.count != 0 {
            string.remove(at: string.index(before: string.endIndex))
        }
        string += "/*"
        string += "\(CONTACT_FILE_DIRECTORY)/\(AWSIdentityManager.default().identityId!)/"
        string += "/*"
        return string
    }
    func getAWSContent(url:String,share:[Int],completionHandler: @escaping (() -> Void)) {
        print("DataHub: loadAWSContent()")
        manager.listAvailableContents(withPrefix: url, marker: marker, completionHandler: {[weak self] (contents: [AWSContent]?, nextMarker: String?, error: Error?) in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Failed to load the list of contents. \(error)")
            }
            if let contents = contents, contents.count > 0 {
                if let nextMarker = nextMarker, !nextMarker.isEmpty {
                    strongSelf.didLoadAllContents = false
                } else {
                    strongSelf.didLoadAllContents = true
                }
                strongSelf.marker = nextMarker
            } else {
                print("DataHub: Contents is empty")
            }
            print("DataHub: downloadRemoteContents(remoteContents, share)")
            strongSelf.downloadRemoteContents(remoteContents: contents!,share:share){
                print("completionHandler()")
                completionHandler()
            }
        })
    }
    
    func downloadRemoteContents(remoteContents: [AWSContent],share:[Int],completionHandler: @escaping (() -> Void)){
        print("DataHub: downloadContents()")
        print(remoteContents)
        remoteContents.forEach({ (content: AWSContent) in
            print("Content: \(content)")
            print("key - \(content.key)")
            print("cached = \(content.isCached)")
            if !content.isDirectory {
                if (content.key.range(of: "contact.json") != nil){
                    if !content.isCached {
                        print("downloadOtherContent called from downloadRemoteContents")
                        downloadOtherContent(content, pinOnCompletion: false, share:share){completionHandler()}
                    } else {
                        print("downloadOther called from downloadRemoteContents")
                        content.removeLocal()
                        downloadOtherContent(content, pinOnCompletion: false, share:share){completionHandler()}
                        //downloadOther(content: content, data: content.cachedData,share:share)
                        //completionHandler()
                    }
                }
            }
        })
    }
    fileprivate func downloadOtherContent(_ content: AWSContent, pinOnCompletion: Bool,share:[Int], completionHandler: @escaping (() -> Void)) {
        print("DataHub: downloadContent(content: \(content), pinOnCompletion: \(pinOnCompletion)")
        content.download(with: .ifNewerExists, pinOnCompletion: pinOnCompletion, progressBlock: {[weak self] (content: AWSContent, progress: Progress) in
            guard let strongSelf = self else { return }
            }, completionHandler: {[weak self] (content: AWSContent?, data: Data?, error: Error?) in
                guard let strongSelf = self else { return }
                if (content != nil){
                    strongSelf.downloadOther(content: content!, data: data!, share:share)
                }
                if let error = error {
                    print("Failed to download a content from a server. \(error)")
                    //AppDelegate.getAppDelegate().showMessage("Failed up download contact info")
                }
                strongSelf.getLocalData()
                strongSelf.syncData()
                completionHandler()
        })
    }
    
    func downloadOther(content: AWSContent, data: Data, share: [Int]){
        var fc = FCContact()
        fc.encodeShareJSON(data: data,share:share)
        self.contacts.append(fc)

        //ask if they will be sending their contact through a text
        let containerview = AppDelegate.getAppDelegate().window?.rootViewController as! ContainerViewController
        let midview = containerview.middleVertScrollVc
        let navReadview = midview?.bottomVc
        //var arrayViewRead   = navReadview?.childViewControllers
        //let readview    = arrayViewRead?[0] as! ReaderViewController
        let readview = navReadview as! ReaderViewController
        print("readview.newestContact = fc")
        readview.newestContact = fc
        
        self.refreshContacts()
    }
    
    func getContactInfo(info:String) -> [String]{
        print("DataHub: getContactInfo(info)")
        let check = info.range(of: "FirstContact/*")
        print("is a first contact string \(check)")
        //make sure the code scanned a FirstContact Code
        if check == nil {
            return ["nil"]
        } else {
            //populate the contactInfoArray
            var removeRange = (info.startIndex ..< (check?.upperBound)!)
            let nString = info.replacingCharacters(in: removeRange, with: "")
            var remCheck = nString.range(of: "remote/*")
            if remCheck == nil {
                let direCheck = nString.range(of: "direct/*")
                if direCheck == nil {
                    return ["nil"]
                }
                removeRange = (nString.startIndex ..< (direCheck?.upperBound)!)
                let fString = nString.replacingCharacters(in: removeRange, with: "")
                return recursiveGetValues(fString, contactInfoArray: [])
            } else {
                removeRange = (nString.startIndex ..< (remCheck?.upperBound)!)
                let sString = nString.replacingCharacters(in: removeRange, with: "")
                let shareRange = sString.range(of: "/*")
                removeRange = (sString.startIndex ..< (shareRange?.upperBound)!)
                
                
                let shareString = sString.substring(to: (shareRange?.lowerBound)!)
                
                
                let fString = sString.replacingCharacters(in: removeRange, with: "")
                return [shareString,getRemoteValues(info: fString)]
            }
        }
    }
    func removeFbData() {
        //Remove FB Data
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        FBSDKAccessToken.setCurrent(nil)
    }
    
    func getRemoteValues(info:String) -> String {
        print("DataHub: getRemoteValues(info)")
        let range = info.range(of: "/*")
        if range == nil { return "nil" }
        let startIndex = range?.lowerBound
        return info.substring(to: startIndex!)
    }
    //recursively gets the values in a formatted string
    func recursiveGetValues(_ string:String,contactInfoArray:[String]) -> [String]{
        print("recursiveGetValues(string:String,contactInfoArray:[String])->[String]")
        var newcontactArray = contactInfoArray
        let range = string.range(of: "/*")
        if range == nil {
            newcontactArray.append(string)
            print("DataHub: \(contactInfoArray)")
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

