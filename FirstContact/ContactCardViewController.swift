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
        cardView.registerCardCell(c: InstagramCardCell.classForCoder(), nib: UINib.init(nibName:"InstagramCardCell", bundle:nil))
        cardView.registerCardCell(c: SnapchatCardCell.classForCoder(), nib: UINib.init(nibName:"SnapchatCardCell", bundle:nil))
        cardView.cardDataSource = self
        let arr = self.generateCardInfo(cardCount: 5)
        cardView.set(cards: arr)
        
        self.cardView.showStyle(style: .cover)
        dataHub = AppDelegate.getAppDelegate().dataHub

    }
    

    
    func generateCardInfo (cardCount:Int) -> [AnyObject] {
        print("ContactCardVC: generateCardInfo")
        var arr = [AnyObject]()
        let xibName = ["NameCard","PhoneCard","EmailCard","InstagramCard","SnapchatCard"]
        
        for i in 0...xibName.count-1 {
            arr.append(xibName[i] as AnyObject)
        }
        
        
        return arr
    }
    
    func cardView(collectionView:UICollectionView,item:AnyObject,indexPath:IndexPath) -> UICollectionViewCell {
        
        if self.contact.me == true {
            self.contact = dataHub.getContact()
        } else if (self.contactIndex != nil){
            self.contact = dataHub.getContacts()[self.contactIndex]
        }
        print("ContactCardVC: cardView(collectionView:,item:,idexPath)")
        print("------ contact getting passed -------")
        print(self.contact)
        print("--------------------------------------")
        
        print("\nCardView entered with \(item), path: \(indexPath)\n")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item as! String, for: indexPath )
        switch cell {
        case let c as BasicCardCell:
            c.titleLabel.text = "BasicCardCell"
        case let c as NameCardCell:
            c.titleLabel.text = "Name"
            c.contact = self.contact //create mutator
            c.contactIndex = self.contactIndex //create mutator
            c.setUpView(pcontact: self.contact, index: self.contactIndex)
            
        case let c as PhoneCardCell:
            c.titleLabel.text = "Phone Number"
            c.contact = self.contact
            c.contactIndex = self.contactIndex
            c.setUpView(pcontact: self.contact, index: self.contactIndex)
        case let c as EmailCardCell:
            c.titleLabel.text = "Email"
            c.contact = self.contact
            c.contactIndex = self.contactIndex
            c.setUpView(pcontact: self.contact,index: self.contactIndex)
        case let c as InstagramCardCell:
            c.titleLabel.text = "Instagram"
            c.contact = self.contact
            c.contactIndex = self.contactIndex
            c.setUpView(pcontact: self.contact, index: self.contactIndex)
        case let c as SnapchatCardCell:
            c.titleLabel.text = "Snapchat"
            c.contact = self.contact
            c.contactIndex = self.contactIndex
            c.setUpView(pcontact: self.contact, index: self.contactIndex)
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
