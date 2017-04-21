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
        
        let homebutton = FCNavigationButton(x: Int(self.view.frame.size.width) - FCNavigationButton.SIZE/2, y: Int(self.view.frame.size.height) - FCNavigationButton.SIZE/2, image: UIImage(named:"QR_right.png")!)
        homebutton.addTarget(nil, action: #selector(downloadContact), for: UIControlEvents.touchUpInside)
        self.view.addSubview(homebutton)
        /*
        manager = AWSUserFileManager.defaultUserFileManager()
        didLoadAllContents = false
        print("RemoteHandler instance created")
        if (AWSIdentityManager.default().isLoggedIn) {
            let userId = AWSIdentityManager.default().identityId!
            prefix = "\(UserFilesPrivateDirectoryName)/\(userId)/"
            marker = nil
            //refreshContents()
            //updateUserInterface()
            loadMoreContents()
            //downloadContact()
            print("asldkfhklajshdf;lkjas;ldkjf;lkasjdf;lkjsadkk ===========\n\n\n\n\n\n\n\n\n\\n")
        }
        
        // dataHub = AppDelegate.getAppDelegate().dataHub*/
        if contact.me == true {
            
        } else {
            
        }
        
        cardView.registerCardCell(c: BasicCardCell.classForCoder(), nib: UINib.init(nibName: "BasicCardCell", bundle: nil))
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
    fileprivate func refreshContents() {
        marker = nil
        loadMoreContents()
    }
    
    fileprivate func loadMoreContents() {
        print("LOAD MORE CONTENT ENTERED")

        print(prefix)
        print(marker)
        manager.listAvailableContents(withPrefix: prefix, marker: marker, completionHandler: {[weak self] (contents: [AWSContent]?, nextMarker: String?, error: Error?) in
            guard let strongSelf = self else { return }
            if let error = error {
                //strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to load the list of contents.", cancelButtonTitle: "OK")
                print("Failed to load the list of contents. \(error)")
            }
            if let contents = contents, contents.count > 0 {
                strongSelf.contents = contents
                
                print("-------------------------------------------------------------------------------")
                print("-----------------------------------CONTENT-------------------------------------")
                print("-------------------------------------------------------------------------------")
                print(contents)
                print("-------------------------------------------------------------------------------")
                print("-------------------------------------------------------------------------------")
                print("-------------------------------------------------------------------------------")
                if let nextMarker = nextMarker, !nextMarker.isEmpty {
                    strongSelf.didLoadAllContents = false
                } else {
                    strongSelf.didLoadAllContents = true
                }
                strongSelf.marker = nextMarker
            } else {
                print("else")
                //strongSelf.checkUserProtectedFolder()
            }
            //if strongSelf.j==2 {
                //strongSelf.downloadContact()
            //}
            //strongSelf.updateUserInterface()

        })

        print("listAvailableContents done")

        
        
        print("loadMoreContents end")
    }
    fileprivate func downloadContent(_ content: AWSContent, pinOnCompletion: Bool) {
        content.download(with: .ifNewerExists, pinOnCompletion: pinOnCompletion, progressBlock: {[weak self] (content: AWSContent, progress: Progress) in
            guard let strongSelf = self else { return }
            //if strongSelf.contents!.contains( where: {$0 == content} ) {
                //strongSelf.tableView.reloadData()
            //}
            }) {[weak self] (content: AWSContent?, data: Data?, error: Error?) in
            guard let strongSelf = self else { return }
                if (content?.key.range(of: ".json") != nil){
                    print("is .json")
                    print("HEHEHEHHEHEHEHEHEHHEH;fldja;lf jl;djfl;kja;f")
                    var cont = FCContact()
                    print("data")
                    print(data)
                    print("contact")
                    print(cont)
                    cont.encodeJSON(data: data!)
                    print("WOKRED")
                    print(cont)
                }
            if let error = error {
                print("Failed to download a content from a server. \(error)")
                //strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to download a content from a server.", cancelButtonTitle: "OK")
            }
            //strongSelf.updateUserInterface()
        }
    }
    func downloadContact(){
        /*//DispatchQueue.main.async {
        print("download Contact")
        var end = self.contents?.count
         print("recent")
         self.contents?.forEach({ (content: AWSContent) in
         print("CONTENT")
         //print(self.content)
         if !content.isCached && !content.isDirectory {
            print("not cached or dir")
            downloadContent(content, pinOnCompletion: false)
         } else {
            print("cached or dir.")
            }
         })
        //}*/
        //dataHub.getAWSContent(url: "protected/us-east-1:6b06eac0-f0d5-4b90-8ceb-c5acb831971c/", share: <#[Int]#>)
        //print(self.dataHub.contacts)
        //AppDelegate.getAppDelegate().dataHub = DataHub()
        AppDelegate.getAppDelegate().dataHub.uploadContact()
        AppDelegate.getAppDelegate().dataHub.uploadContacts()
    }
    
    func generateCardInfo (cardCount:Int) -> [AnyObject] {
        var arr = [AnyObject]()
        let xibName = ["NameCard","BasicCard","PhoneCard","EmailCard","InstagramCard","SnapchatCard"]
        
        //for i in 1...cardCount {
        for i in 0...xibName.count-1 {
            arr.append(xibName[i] as AnyObject)
        }
        
        
        return arr
    }
    
    func cardView(collectionView:UICollectionView,item:AnyObject,indexPath:IndexPath) -> UICollectionViewCell {
        print("cardView entered with \(item), path: \(indexPath)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item as! String, for: indexPath )
        switch cell {
        case let c as BasicCardCell:
            c.titleLabel.text = "BasicCardCell"
        case let c as NameCardCell:
            c.titleLabel.text = "Name"
            c.contact = self.contact //create mutator
            c.contactIndex = self.contactIndex //create mutator
            c.setUpView()
            
        case let c as PhoneCardCell:
            c.titleLabel.text = "Phone Number"
            c.contact = self.contact
            c.contactIndex = self.contactIndex
            c.setUpView()
        case let c as EmailCardCell:
            c.titleLabel.text = "Email"
            c.contact = self.contact
            c.contactIndex = self.contactIndex
            c.setUpView()
        case let c as InstagramCardCell:
            c.titleLabel.text = "Instagram"
            c.contact = self.contact
            c.contactIndex = self.contactIndex
            c.setUpView()
        case let c as SnapchatCardCell:
            c.titleLabel.text = "Snapchat"
            c.contact = self.contact
            c.contactIndex = self.contactIndex
            c.setUpView()
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
