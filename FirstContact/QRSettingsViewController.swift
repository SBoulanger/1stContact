//
//  QRSettingsViewController.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 8/18/16.
//  Copyright © 2016 Samuel Boulanger. All rights reserved.
// tuesday at 2

import Foundation
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class QRSettingsViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    var categories = ["Categories","Individual"]
    
    var dataHub:DataHub!
    
    @IBOutlet weak var mainTableView: UITableView!
    
    var array0 = ["Basic","Social","Custom +"]
    
    var array1 = ["Name","Phone Number","Email","Facebook","Instagram","Snapchat","Twitter"]
    
    override func viewDidLoad(){
        super.viewDidLoad()
        print("LOAD QRVIEWCONTROLLER")

        // Do any additional setup after loading the view.
        
        self.dataHub = AppDelegate.getAppDelegate().dataHub
        print(dataHub.share)

        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        
        self.mainTableView.dataSource = self
        self.mainTableView.delegate = self
        
        self.mainTableView.allowsMultipleSelection = true
        
        self.title = "Share"
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: UIFont(name: "KohinoorBangla-Light", size: 23)!,
                NSForegroundColorAttributeName: UIColor.green])
        
        
        let homebutton = FCNavigationButton(x: Int(self.view.frame.size.width) - FCNavigationButton.SIZE/2, y: Int(self.view.frame.size.height) - FCNavigationButton.SIZE/2, image: UIImage(named:"QR_right.png")!)
        homebutton.setUpRightButton()
        self.view.addSubview(homebutton)
        
        /*for i in dataHub.share {
            selectRow(tableView: mainTableView, at: IndexPath(row: i, section: 1))
        }*/
        //let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        //self.navigationController?.navigationBar.titleTextAttributes = titleDict as! [String : AnyObject]
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    

    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return array0.count
        }
        else {
            return array1.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CategoryRow
        
        if (indexPath as NSIndexPath).section == 0 {
            cell.cellLabel.text = array0[(indexPath as NSIndexPath).row]
            cell.cellValue.text = ""
        } else {
            cell.cellLabel.text = array1[(indexPath as NSIndexPath).row]
            if (indexPath as NSIndexPath).row == 0 {
                cell.cellValue.text = dataHub.contact.getField(fieldIndex: (indexPath as NSIndexPath).row) + " " + dataHub.contact.getField(fieldIndex: (indexPath as NSIndexPath).row + 1)
            } else if (indexPath as NSIndexPath).row != 0 {
                cell.cellValue.text = dataHub.contact.getField(fieldIndex: (indexPath as NSIndexPath).row + 1)
            }
            if dataHub.share.contains((indexPath as NSIndexPath).row) {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition(rawValue: Int(tableView.contentOffset.y))!)
                cell.layer.backgroundColor = UIColor(colorLiteralRed: 0, green: 254/255, blue: 10/255, alpha: 0.4).cgColor
            }
        }
        
        cell.selectionStyle = .none
        
        //cell.pressID.layer.masksToBounds = true
        //cell.pressID.layer.cornerRadius = 0.5 * cell.pressID.bounds.size.width
        
        //cell.pressID.backgroundColor = UIColor.white
        //cell.pressID.layer.borderColor = UIColor.green.cgColor
        //cell.pressID.layer.borderWidth = 2
        return cell
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
        if dataHub.share.contains((indexPath as NSIndexPath).row) {
            tableView.selectRow(at: indexPath as IndexPath, animated: true, scrollPosition: UITableViewScrollPosition(rawValue: Int(tableView.contentOffset.y))!)
            cell.layer.backgroundColor = UIColor(colorLiteralRed: 0, green: 254/255, blue: 10/255, alpha: 0.4).cgColor
        }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let cell : CategoryRow = tableView.cellForRow(at: indexPath)! as! CategoryRow
        if (indexPath.row == 0 && indexPath.section == 0) { //Basic
            selectRow(tableView: tableView, at: IndexPath(row: 0, section: 1))
            selectRow(tableView: tableView, at: IndexPath(row: 1, section: 1))
            selectRow(tableView: tableView, at: IndexPath(row: 2, section: 1))
        }
        if (indexPath.row == 1 && indexPath.section == 0) { //Social
            selectRow(tableView: tableView, at: IndexPath(row: 3, section: 1))
            selectRow(tableView: tableView, at: IndexPath(row: 4, section: 1))
            selectRow(tableView: tableView, at: IndexPath(row: 5, section: 1))
            selectRow(tableView: tableView, at: IndexPath(row: 6, section: 1))
        }
        var selectedRowsIndexPath = tableView.indexPathsForSelectedRows
        var selectedRows = [Int]()
        if selectedRowsIndexPath != nil {
            for i in selectedRowsIndexPath! {
                if i.section != 0 {
                    selectedRows.append(i.row)
                }
            }
            print(selectedRows)
        }
        
        self.dataHub.setShare(nshare: selectedRows)
        //self.dataHub.contact.share = selectedRows
        self.dataHub.generateContactInfo()
        var conview = AppDelegate.getAppDelegate().window?.rootViewController as! ContainerViewController
        var navview = conview.middleVc
        var array = navview?.childViewControllers
        var qrview = array?[0] as! QRViewController
        qrview.generateNewImage()
        
        
        //cell.pressID.backgroundColor = UIColor.green
        cell.layer.backgroundColor = UIColor(colorLiteralRed: 0, green: 254/255, blue: 10/255, alpha: 0.4).cgColor
    }
    func selectRow(tableView:UITableView,at index:IndexPath){
        let cell : CategoryRow = tableView.cellForRow(at: index)! as! CategoryRow
        tableView.selectRow(at: index, animated: true, scrollPosition:UITableViewScrollPosition(rawValue: Int(tableView.contentOffset.y))!)
        cell.layer.backgroundColor = UIColor(colorLiteralRed: 0, green: 254/255, blue: 10/255, alpha: 0.4).cgColor
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.white //UIColor(red: 0/255, green: 181/255, blue: 229/255, alpha: 1.0) //make the background color light blue
        header.textLabel?.textColor = UIColor.green //make the text white
        header.alpha = 1.0 //make the header transparent
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        /*let contactData = UserDefaults.standard.data(forKey: "contact")
        contact = NSKeyedUnarchiver.unarchiveObject(with: contactData!) as! CNContact
        
        //if the qrcode has not been loaded yet
        if qrCodeImage == nil {
            //create the image
            qrCodeView.image = generateCode()
            displayQRCodeImage()
        }*/

        
        
        let cell : CategoryRow = tableView.cellForRow(at: indexPath)! as! CategoryRow
        if indexPath.row == 0 && indexPath.section == 0{ //Basic
            deselectRow(tableView: tableView, at: IndexPath(row: 0, section: 1))
            deselectRow(tableView: tableView, at: IndexPath(row: 1, section: 1))
            deselectRow(tableView: tableView, at: IndexPath(row: 2, section: 1))
        }
        if (indexPath.row == 1 && indexPath.section == 0) { //Social
            deselectRow(tableView: tableView, at: IndexPath(row: 3, section: 1))
            deselectRow(tableView: tableView, at: IndexPath(row: 4, section: 1))
            deselectRow(tableView: tableView, at: IndexPath(row: 5, section: 1))
            deselectRow(tableView: tableView, at: IndexPath(row: 6, section: 1))
        }
        var selectedRowsIndexPath = tableView.indexPathsForSelectedRows
        var selectedRows = [Int]()
        if selectedRowsIndexPath != nil {
            for i in selectedRowsIndexPath! {
                if i.section != 0 {
                    selectedRows.append(i.row)
                }
            }
            print(selectedRows)
        }
        
        self.dataHub.setShare(nshare: selectedRows)
        self.dataHub.contact.share = selectedRows
        self.dataHub.generateContactInfo()
        
        var conview = AppDelegate.getAppDelegate().window?.rootViewController as! ContainerViewController
        var navview = conview.middleVc
        var array = navview?.childViewControllers
        var qrview = array?[0] as! QRViewController
        qrview.generateNewImage()
        
        cell.layer.backgroundColor = UIColor.white.cgColor
    }
    func deselectRow(tableView:UITableView,at index:IndexPath){
        let cell : CategoryRow = tableView.cellForRow(at: index)! as! CategoryRow
        tableView.deselectRow(at: index, animated: true)
        cell.layer.backgroundColor = UIColor.white.cgColor
    }
    
    func setNewQRCode(selected: Array<Int>){
        print("hi")
    }
    
    
}
