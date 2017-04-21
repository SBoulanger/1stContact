//
//  SettingsViewController.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 3/20/16.
//  Copyright © 2016 Samuel Boulanger. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import ContactsUI
import AWSMobileHubHelper

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CNContactViewControllerDelegate {
    
    var rootController: UINavigationController?
    var window: UIWindow?
    
    let keysToFetch: [CNKeyDescriptor] = [CNContactIdentifierKey as CNKeyDescriptor, CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactViewController.descriptorForRequiredKeys()]
    //@IBOutlet weak var chooseDifContactButton: UIButton!
    
    //@IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var historyTableView: UITableView!
    
    let defaults = UserDefaults.standard
    //let testName = ["Kate Bell","Anna Hara","Taylor David","Hank M. Zakroff","Daniel Higgins Jr."]
    
    //var swipeView:PassThroughView!
    
    var dataHub: DataHub!
    
    var historyArry: [String]!
    //var contactHistoryArray: [FCContact]!
    
    var infoAnimated: Bool?
    var skipTutorial: Bool?
    
    var signInObserver: AnyObject!
    var signOutObserver: AnyObject!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //self.navigationController?.navigationBarHidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        //get contact history array
    }
    
    func refresh(){
        historyTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //clearData()
        
        signInObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignIn, object: AWSIdentityManager.default(), queue: OperationQueue.main, using: {[weak self] (note: Notification) -> Void in
            guard let strongSelf = self else { return }
            print("Sign In Observer observed sign in.")
            strongSelf.setUpLogButton()
            // You need to call `updateTheme` here in case the sign-in happens after `- viewWillAppear:` is called.
            //strongSelf.updateTheme()
        })
        
        signOutObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignOut, object: AWSIdentityManager.default(), queue: OperationQueue.main, using: {[weak self](note: Notification) -> Void in
            guard let strongSelf = self else { return }
            print("Sign Out Observer observed sign out.")
            strongSelf.setUpLogButton()
            //strongSelf.updateTheme()
        })
        setUpLogButton()

        self.dataHub =  AppDelegate.getAppDelegate().dataHub
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white

        self.title = "Contacts"
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: UIFont(name: "KohinoorBangla-Light", size: 23)!,
                NSForegroundColorAttributeName: UIColor.green])
        self.navigationController?.navigationBar.tintColor = UIColor.green
        
        
        infoAnimated = false
        skipTutorial = defaults.bool(forKey: "skipTutorial")
        
        print("ContactsViewController entered")
        
        //get contact history array
        print("historyArray size \(dataHub.getContacts().endIndex + 1) \n hisotryContactArray size \(dataHub.getContacts().endIndex + 1)")
        historyTableView.dataSource = self
        historyTableView.delegate = self
        //historyTableView.tableFooterView = UIView()
        print("View Did Load")
        
        let homebutton = FCNavigationButton(x: -FCNavigationButton.SIZE/2, y: Int(self.view.frame.size.height) - FCNavigationButton.SIZE/2, image: UIImage(named:"QR_left.png")!)
        homebutton.setUpLeftButton()
        print("CONTACTS")
        print(self.view.frame.size.height)
        print(homebutton)
        self.view.addSubview(homebutton)
        
        //view.addSubview(historyTableView)
        //view.bringSubview(toFront: historyTableView)
    }
    func handleLogout() {
        if (AWSIdentityManager.default().isLoggedIn) {
            AWSIdentityManager.default().logout(completionHandler: {(result: Any?, error: Error?) in
                //self.navigationController!.popToRootViewController(animated: false)
                // Create the alert controller
                let alertController = UIAlertController(title: "☄️", message: "Remove local data?", preferredStyle: .alert)
                
                // Create the actions
                let okAction = UIAlertAction(title: "Remove", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.dataHub.wipeData()
                }
                let cancelAction = UIAlertAction(title: "Don't Remove", style: UIAlertActionStyle.cancel) {
                    UIAlertAction in
                    print("Don't Remove Pressed")
                }
                
                // Add the actions
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                
                // Present the controller
                self.present(alertController, animated: true, completion: nil)
                self.setUpLogButton()
            })
            // print("Logout Successful: \(signInProvider.getDisplayName)");
        } else {
            assert(false)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return dataHub.getSortedAArrays()[section - 1].count
        }
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var array:[String] = []
        if (dataHub.getSortedAArrays().count > 0){
            for i in 0...dataHub.getSortedAArrays().count - 1{
                if dataHub.getSortedAArrays()[i][0].firstName.characters.first == nil {
                    array.append("@")
                }
                else {
                    array.append(String(dataHub.getSortedAArrays()[i][0].firstName.characters.first!))
                }
            }
        }
        return array
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.white //UIColor(red: 0/255, green: 181/255, blue: 229/255, alpha: 1.0) //make the background color light blue
        header.textLabel?.textColor = UIColor.green //make the text white
        header.alpha = 1.0 //make the header transparent
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        }
        if dataHub.getSortedAArrays()[section-1][0].firstName.characters.first == nil {
            return "etc"
        }
        return String(dataHub.getSortedAArrays()[section-1][0].firstName.characters.first!)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataHub.getSortedAArrays().count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellIndentifier: String = "HistoryTableCell"
        
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: CellIndentifier)! //as! CategoryRow
        
        if (indexPath.row == 0 && indexPath.section == 0){
            cell.textLabel?.text = "me"
            cell.textLabel?.font = ButtonStyle.fontBold

        } else if indexPath.section >= 1 {
            cell.textLabel?.text = getContactNameLabel(dataHub.getSortedAArrays()[(indexPath as NSIndexPath).section - 1][(indexPath as NSIndexPath).row])
            cell.textLabel?.font = ButtonStyle.font
        }
        return cell
    }
    func setUpLogButton(){
        if !AWSIdentityManager.default().isLoggedIn{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign In", style: .plain, target: self, action: #selector(showSignInViewController))
        }
        if AWSIdentityManager.default().isLoggedIn{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleLogout))
        }
    }
    
    //gets the first last name from a contact
    func getContactNameLabel(_ contact:FCContact)->String{
        if (contact.firstName + contact.lastName == ""){
            return "NO NAME"
        }
        return contact.firstName + " " + contact.lastName
    }
    func getIndexOfContact(section:Int,row:Int) -> Int{
        var index = 0
        if (section > 1){
            for s in 2...section{
                index = index + dataHub.getSortedAArrays()[s-2].count
            }
        }
        return index + row
    }
    
    //opens a contact view when contact is selected from tableview
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //get the contact
        var rowcontact: FCContact!
        if indexPath.row == 0 && indexPath.section == 0  {
            rowcontact = dataHub.getContact()
        }else{
            rowcontact = self.dataHub.getContacts()[getIndexOfContact(section: indexPath.section, row: indexPath.row)]
        }
        //create the controller with the contact
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "contactcardviewcontroller") as! ContactCardViewController
//NOTE::

        if (indexPath.row == 0 && indexPath.section == 0){
            rowcontact.me = true
        }else {
            controller.contactIndex = getIndexOfContact(section: indexPath.section, row: indexPath.row)
        }
        //showSignInViewController()
        controller.contact = rowcontact
        //desect row to rid the grey tone
        tableView.deselectRow(at: indexPath, animated: false)
        //presents the view controller and shows the navigation bar so they can return back
        self.navigationController?.show(controller, sender: nil)
 
        //self.navigationController?.pushViewController(controller, animated: false)
    }
    func showSignInViewController() {
        let signInSB = UIStoryboard(name: "SignIn", bundle: nil)
        let signinVC = signInSB.instantiateInitialViewController()! as UIViewController
        signinVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(signinVC, animated: false, completion: nil)
    }

    //adds the delete action for the table view cells (delete contact from table)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?  {
        if (indexPath.row != 0){
        //create the delete action
        let deleteTableViewAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete" , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            
            let confirmationController = UIAlertController(title: nil, message: "Are you sure you want to Delete?", preferredStyle: .actionSheet)
            
            //handles the action of agreeing to delete contact
            let agreeAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action) -> Void in
                //delete the contact
                print("delete")
                //delete actions go here VVV
                self.dataHub.deleteContact(contactAt: (indexPath as NSIndexPath).row)
                //reload data on table view
                self.historyTableView.reloadData()
            })
            //actions the handles if delete was not intended
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            //add them to controller
            confirmationController.addAction(agreeAction)
            confirmationController.addAction(cancelAction)
            
            //present the controller when delete is pressed
            self.present(confirmationController, animated: true, completion: nil)
        })
            return [deleteTableViewAction]
        }
        return nil
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .delete {
            confirmDelete(row: indexPath.row - 1)
        }
    }
    
    func confirmDelete(row: Int) {
        let alert = UIAlertController(title: "Delete?", message: "Are you sure you want to permanently delete?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(action) -> Void in
            //delete the contact
            print("delete")
            //delete actions go here VVV
            self.dataHub.deleteContact(contactAt: row)
            //reload data on table view
            self.historyTableView.reloadData()
        })
        let cancelDelete = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alert.addAction(DeleteAction)
        alert.addAction(cancelDelete)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        //alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //create data from the contact array
    func createDatafromContactArray(_ contacts:[Dictionary<String, AnyObject>]) -> Data {
        /*var array = [Dictionary<String, AnyObject>]()
        for i in contacts {
            array.append(i.encode())
        }*/
        let data = NSKeyedArchiver.archivedData(withRootObject: contacts)
        return data
    }    
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactView" {
            var contactController = segue.destination as! ContactViewController
            //add contact information here VVVV
            
        }
    }*/
    

    
    //TODO:add date the contact was added and inverse order from newest to oldest
}


