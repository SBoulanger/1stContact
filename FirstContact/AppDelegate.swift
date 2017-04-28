//
//  AppDelegate.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 9/30/15.
//  Copyright © 2015 Samuel Boulanger. All rights reserved.
//

import UIKit
import Contacts
import FBSDKLoginKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var didInit : Bool! = false
    
    private let KEY : String! = "key14fc39en31cr1ja9en0j511jsline"
    
    var dataLoaded : Bool! = false
    
    var contactStore = CNContactStore()
    
    var contact: FCContact!

    var dataHub: DataHub!
    
    var container: ContainerViewController!
    
    var window: UIWindow?
    //var rootController: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Fabric.with([Twitter.self])
        // Override point for customization after application launch.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        //let twitter = Twitter.sharedInstance()
        //let oauthSigning = TWTROAuthSigning(authConfig:twitter.authConfig, authSession:twitter.sessionStore.session() as! TWTRSession)
        
        //SNAPCHAT
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let middle = storyboard.instantiateViewController(withIdentifier: "middle")
        let left = storyboard.instantiateViewController(withIdentifier: "left")
        let right = storyboard.instantiateViewController(withIdentifier: "right")
        //let top = storyboard.instantiateViewController(withIdentifier: "top")
        let bottom = storyboard.instantiateViewController(withIdentifier: "bottom")
            
        let snapContainer = ContainerViewController.containerViewWith(left,
                                                                              middleVC: middle,
                                                                              rightVC: right,
                                                                              /*topVC: top,*/
                                                                              bottomVC: bottom)
        
        self.window?.rootViewController = snapContainer
        self.container = snapContainer
        self.window?.makeKeyAndVisible()
        
        return AWSMobileClient.sharedInstance.didFinishLaunching(application, withOptions: launchOptions)
        //return true
    }
    
    
    /*func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, didFinishLaunchingWithOptions: options)
    }*/
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if (url.scheme == "fb1095985637117757"){
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        } else {
            return AWSMobileClient.sharedInstance.withApplication(application, withURL: url, withSourceApplication: sourceApplication, withAnnotation: annotation)
        }
    }
    /*func application(app: UIApplication, openURL url: URL, options: [String : AnyObject]) -> Bool {
        /*if Twitter.sharedInstance().application(app, open:url, options: options) {
            return true
        }*/
        
        // If you handle other (non Twitter Kit) URLs elsewhere in your app, return true. Otherwise
        return true
    }*/

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if (!didInit){
            self.dataHub = DataHub()
        }
        didInit = true
        AWSMobileClient.sharedInstance.applicationDidBecomeActive(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func setLoaded(loaded : Bool){
        self.dataLoaded = loaded
    }
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    func showMessage(_ message: String) {
        print("showMessage class called")
        let alertController = UIAlertController(title: "FirstContact 👽" ,message: message ,preferredStyle: UIAlertControllerStyle.alert)
        
        let dismissAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) { (action) -> Void in
        }
        
        alertController.addAction(dismissAction)
        
        let pushedViewControllers = (self.window?.rootViewController as! UINavigationController).viewControllers
        let presentedViewController = pushedViewControllers[pushedViewControllers.count - 1]
        DispatchQueue.main.async(execute: {
            presentedViewController.present(alertController, animated: true, completion: nil)
        })
    }
    func requestForAccess(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            print("access granted")
            completionHandler(true)
            
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    print("access granted")
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let message = "\(accessError!.localizedDescription)\nPlease allow access to your contacts through the Settings..."
                            self.showMessage(message)
                        })
                    }
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    func retrieveContacts(completion: (_ success: Bool, _ contacts: [FCContact]?) -> Void) -> [FCContact] {
        var contacts = [FCContact]()
        do {
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor])
            try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock: { (cnContact, error) in
                if let contact = FCContact(cnContact: cnContact) {
                    contacts.append(contact)
                }
            })
            completion(true, contacts)
        } catch {
            completion(false, nil)
        }
        return contacts
    }
    func showSimpleAlertWithTitle(_ title: String, message: String, cancelButtonTitle cancelTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let pushedViewControllers = (self.window?.rootViewController as! UINavigationController).viewControllers
        let presentedViewController = pushedViewControllers[pushedViewControllers.count - 1]
        DispatchQueue.main.async(execute: {
            presentedViewController.present(alertController, animated: true, completion: nil)
        })
    }
    func ResizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func getKey() -> String {
        return self.KEY
    }

}

