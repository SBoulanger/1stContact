//
//  ContactCardViewController.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 3/10/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import MMCardView
import UIKit
import AWSMobileHubHelper

import ObjectiveC

class ContactCardViewController: UIViewController, CardCollectionViewDataSource {
    
    @IBOutlet weak var cardView: CardView!
    
    
    fileprivate var prefix: String!
    fileprivate var manager: AWSUserFileManager!
    fileprivate var contents: [AWSContent]?
    fileprivate var didLoadAllContents: Bool!
    fileprivate var marker: String?
    
    var nameCardCell : NameCardCell!
    var phoneCardCell: PhoneCardCell!
    var emailCardCell: EmailCardCell!
    var facebookCardCell: FacebookCardCell!
    var instagramCardCell: InstagramCardCell!
    var snapchatCardCell: SnapchatCardCell!
    
    
    var cellArray : [CardCell]!
    
    var contact: FCContact!
    var contactIndex: Int!
    var dataHub: DataHub!
    var j = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ContactCardVC:viewDidLoad")
        
        if contact.me == true {
            
        } else {
            
        }
        
        //cardView.registerCardCell(c: BasicCardCell.classForCoder(), nib: UINib.init(nibName: "BasicCardCell", bundle: nil))
        cardView.registerCardCell(c: NameCardCell.classForCoder(), nib: UINib.init(nibName: "NameCardCell", bundle:nil))
        cardView.registerCardCell(c: PhoneCardCell.classForCoder(), nib: UINib.init(nibName:"PhoneCardCell", bundle:nil))
        cardView.registerCardCell(c: EmailCardCell.classForCoder(), nib: UINib.init(nibName:"EmailCardCell", bundle:nil))
        cardView.registerCardCell(c: FacebookCardCell.classForCoder(), nib: UINib.init(nibName:"FacebookCardCell", bundle:nil))
        cardView.registerCardCell(c: InstagramCardCell.classForCoder(), nib: UINib.init(nibName:"InstagramCardCell", bundle:nil))
        cardView.registerCardCell(c: SnapchatCardCell.classForCoder(), nib: UINib.init(nibName:"SnapchatCardCell", bundle:nil))
        cardView.cardDataSource = self
        let arr = self.generateCardInfo(cardCount: 6)
        cardView.set(cards: arr)
        
        if (!self.contact.me){
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"Trash-50.png"), style: .plain, target: self, action: #selector(deleteContactPressed))
            //t l b r
            self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsetsMake(13.0, 8.0, 13.0, 14.0)
            //UIEdg
        }
        self.cardView.showStyle(style: .cover)
        dataHub = AppDelegate.getAppDelegate().dataHub
        
        //cellArray = [nameCardCell,phoneCardCell,emailCardCell,instagramCardCell,snapchatCardCell]

    }
    func deleteContactPressed(){
        let actionHandler = {(action:UIAlertAction!) -> Void in
            self.dataHub.deleteContact(contactAt: self.contactIndex)
            self.dataHub.refreshContacts()
            self.navigationController?.popToRootViewController(animated: true)
        }
        let alertController = UIAlertController(title: title, message: "Are you sure you want to delete?", preferredStyle: UIAlertControllerStyle.alert)
        
        let dismissHandler = {(action:UIAlertAction!) -> Void in
            print("Not Sure")
        }
        
        let dismissAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: dismissHandler)
        let sendAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: actionHandler)
        
        alertController.addAction(dismissAction)
        alertController.addAction(sendAction)
        
        print("qrcode set to not done")
        
        present(alertController, animated: true, completion: nil)

    }
    func updateCells(){
        if self.contact.me == true {
            self.contact = dataHub.getContact()
        } else if (self.contactIndex != nil){
            self.contact = dataHub.getContacts()[self.contactIndex]
        }
        nameCardCell.contact = self.contact
        phoneCardCell.contact = self.contact
        emailCardCell.contact = self.contact
        instagramCardCell.contact = self.contact
        snapchatCardCell.contact = self.contact
        
    }
    
    
    func generateCardInfo (cardCount:Int) -> [AnyObject] {
        print("ContactCardVC: generateCardInfo")
        var arr = [AnyObject]()
        let xibName = ["NameCard","PhoneCard","EmailCard","FacebookCard","InstagramCard","SnapchatCard"]
        
        for i in 0...xibName.count-1 {
            arr.append(xibName[i] as AnyObject)
        }
        
        
        return arr
    }
    
    func cardView(collectionView:UICollectionView,item:AnyObject,indexPath:IndexPath) -> UICollectionViewCell {
        print("ContactCardVC: cardView(collectionView:,item:,indexPath:)")
        
        if self.contact.me == true {
            self.contact = dataHub.getContact()
        } else if (self.contactIndex != nil){
            self.contact = dataHub.getContacts()[self.contactIndex]
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item as! String, for: indexPath )
        switch cell {
        case let c as BasicCardCell:
            c.titleLabel.text = "BasicCardCell"
        case let c as NameCardCell:
            c.titleLabel.text = "Name"
            c.contact = self.contact //create mutator
            c.contactIndex = self.contactIndex //create mutator
            c.setUpView(controller:self)
            self.nameCardCell = c
        case let c as PhoneCardCell:
            c.titleLabel.text = "Phone Number"
            self.phoneCardCell = c
            c.contact = self.contact
            c.contactIndex = self.contactIndex
            c.setUpView(controller: self)
        case let c as EmailCardCell:
            c.titleLabel.text = "Email"
            self.emailCardCell = c
            c.contact = self.contact
            c.contactIndex = self.contactIndex
            c.setUpView(controller: self)
        case let c as FacebookCardCell:
            c.titleLabel.text = "Facebook"
            self.facebookCardCell = c
            c.contact = self.contact
            c.contactIndex = self.contactIndex
            c.setUpView(controller: self)
        case let c as InstagramCardCell:
            c.titleLabel.text = "Instagram"
            c.contact = self.contact
            c.contactIndex = self.contactIndex
            self.instagramCardCell = c
            c.setUpView(controller: self)
        case let c as SnapchatCardCell:
            c.titleLabel.text = "Snapchat"
            c.contact = self.contact
            c.contactIndex = self.contactIndex
            self.snapchatCardCell = c
            c.setUpView(controller: self)
            //let v = Int(arc4random_uniform(5))+1
            //c.imgV.image = UIImage.init(named: "image\(v)")
/*
        case let c as CardCCell:
            c.clickCallBack {
                if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Second") as? SecondViewController {
                    vc.delegate = self
                    self.card.presentViewController(to: vc)
                }
            }
 */
        default:
            return UICollectionViewCell()
            
        }
        return cell
    }
    /*
    @IBAction func segmentAction(seg:UISegmentedControl) {
        if (seg.selectedSegmentIndex == 0) {
            self.cardView.showStyle(style: .cover)
        } else {
            self.cardView.showStyle(style: .normal)
        }
    }
    */
    /*@IBAction func filterAction () {
        let sheet = UIAlertController.init(title: "Filter", message: "Select you want to show in View", preferredStyle: .actionSheet)
        
        let cellA = UIAlertAction(title: "CellA", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.card.filterAllDataWith(isInclued: { (idex, obj) -> Bool in
                return (obj as! String) == "CardA"
            })
        })
        
        let cellB = UIAlertAction(title: "CellB", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.card.filterAllDataWith(isInclued: { (idex, obj) -> Bool in
                return (obj as! String) == "CardB"
            })
        })
        
        let cellC = UIAlertAction(title: "CellC", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.card.filterAllDataWith(isInclued: { (idex, obj) -> Bool in
                return (obj as! String) == "CardC"
            })
        })
        let ac = ["CardA","CardC"]
        let cellAC = UIAlertAction(title: "CellA,CellC", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
            self.card.filterAllDataWith(isInclued: { (idex, obj) -> Bool in
                return ac.contains(obj as! String)
            })
        })
        
        let allCell = UIAlertAction(title: "CellAll", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.card.showAllData()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        sheet.addAction(cellA)
        sheet.addAction(cellB)
        sheet.addAction(cellC)
        sheet.addAction(cellAC)
        
        sheet.addAction(allCell)
        sheet.addAction(cancelAction)
        self.present(sheet, animated: true, completion: nil)
    }
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
/*
extension ViewController:SecondViewProtocol {
    func removeCard() {
        card.removeSelectCard()
    }
}
*/
