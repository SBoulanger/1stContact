//
//  QRViewController.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 10/29/15.
//  Copyright © 2015 Samuel Boulanger. All rights reserved.
//
//

//

import UIKit
import Foundation
import Contacts
import ContactsUI
import AWSMobileHubHelper

let UserFilesPrivateDirectoryName = "private"
let contactsDataDirectoryName = "contacts"

class QRViewController: UIViewController  {
    
    
    fileprivate var manager: AWSUserFileManager!
    fileprivate var contents: [AWSContent]?
    fileprivate var didLoadAllContents: Bool!
    fileprivate var marker: String?
    
    //qrcode image
    var qrCodeImage: CIImage!
    //qrcode view
    @IBOutlet weak var qrCodeView: UIImageView!
    //contact info
    var dataHub: DataHub!
    var contact: FCContact!
    var phoneNumber: String!
    
    let defaults = UserDefaults.standard
    
    var prefix: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.getAppDelegate().dataHub = DataHub()
        let logo = UIImage(named: "FC_logo_white.png")
        let newim = ResizeImage(logo!, targetSize: CGSize(width: 40,height: 50))
        //let imageView = UIImageView(image:newim)
        let camButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
        camButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: -2)
        camButton.setImage(newim, for: .normal)
        
        self.navigationItem.titleView = camButton
        //let camButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        //camButton.setImage(UIImage(named:"camera_clear.png"), for: .normal)
        //camButton.layer.cornerRadius = 3.5
        //camButton.layer.borderWidth = 0.25
        //camButton.layer.borderColor = UIColor.lightGray.cgColor
        //camButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 1.5, bottom: 1, right: 1.5)
        camButton.addTarget(nil, action: #selector(AppDelegate.getAppDelegate().container.moveDown), for: .touchUpInside)
        
        //let camBarButton = UIBarButtonItem(customView: camButton)
        //self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsetsMake(17.0, 17.0, 55.0, 55.0)

        //let camButton = UIBarButtonItem(image: ResizeImage(UIImage(named:"camera.png")!,targetSize: CGSize(width: 10,height:10)), style: UIBarButtonItemStyle.plain, target: nil, action: #selector(AppDelegate.getAppDelegate().container.moveDown))
        //self.navigationItem.rightBarButtonItem = camBarButton
        self.dataHub =  AppDelegate.getAppDelegate().dataHub
        
        print("QRViewController viewDidLoad() entered...")
        
        
        let rightButton = FCNavigationButton(x: Int(self.view.bounds.width) - FCNavigationButton.SIZE/2, y: Int(self.view.frame.size.height) - FCNavigationButton.SIZE/2, image: UIImage(named: "User.png")! )
        print(Int((self.navigationController?.navigationBar.frame.size.height)!))
        rightButton.setUpRightButton()
        
        self.contact = self.dataHub.getContact()
        
        let leftButton = FCNavigationButton(x: -FCNavigationButton.SIZE/2, y: Int(self.view.bounds.height) - FCNavigationButton.SIZE/2, image: UIImage(named:"List.png")!)
        leftButton.setUpLeftButton()
        
        //if the qrcode has not been loaded yet
        if qrCodeImage == nil {
            print("qrCodeImage NIL")
            generateNewImage()
        }
        self.view.addSubview(rightButton)
        self.view.addSubview(leftButton)
        contact.getDefaultJSON()
        //setUpAWSContent()

    }
    func setUpAWSContent(){
        manager = AWSUserFileManager.defaultUserFileManager()
        didLoadAllContents = false
        print("RemoteHandler instance created")
        if (AWSIdentityManager.default().isLoggedIn) {
            print("is Logged In")
            let userId = AWSIdentityManager.default().identityId!
            prefix = "\(UserFilesPrivateDirectoryName)/\(userId)/"
            refreshContents()
            //updateUserInterface()
            loadMoreContents()
            //downloadContact()
        }
        
    }
    fileprivate func refreshContents() {
        marker = nil
        loadMoreContents()
    }
    
    func downloadContact(){
        print(contents)
        var end = contents?.count
        for var i in 0...end!{
            contents?[0].download(with: .ifNewerExists, pinOnCompletion: false, progressBlock: nil, completionHandler: {[weak self] (content: AWSContent?, data: Data?, error:Error?) in
                
                if (content?.key.range(of: ".json") != nil){
                    print("HEHEHEHHEHEHEHEHEHHEH;fldja;lf jl;djfl;kja;f")
                    var cont = FCContact()
                    cont.encodeJSON(data: data!)
                    print("WOKRED")
                }
            })
        }
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
            //strongSelf.updateUserInterface()
        })
        print("listAvailableContents done")
        print("loadMoreContents end")
    }

    func generateNewImage(){
        qrCodeView.image = generateCode()
        displayQRCodeImage()
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
    
    //sizes the image
    func resizeImage(_ image: UIImage, withQuality quality: CGInterpolationQuality, rate: CGFloat) -> UIImage {
        //set variables
        //scale the width and height
        let h = image.size.height*rate
        let w = image.size.width*rate
        let size = CGSize(width: w, height: h)
        let isOpaque = true
        //make the graphics for the qrcode
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, 0)
        let context = UIGraphicsGetCurrentContext()
        context!.interpolationQuality = quality
        image.draw(in: CGRect(x: 0, y: 0, width: w, height: h))
        let resized = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resized!;
    }
    //generates the embended code from the string info and returns the image
    func generateCode() -> UIImage {
        //get the filder to generate qrcode
        let filter = CIFilter(name: "CIQRCodeGenerator")
        //get the string info
        print("generate string")
        //transfer the data into a string
        let data = dataHub.code.data(using: String.Encoding.utf8)
        //set the data through the filter
        filter!.setValue("Q", forKey:"inputCorrectionLevel")
        filter!.setValue(data, forKey:"inputMessage")
        //get the output image
        self.qrCodeImage = filter!.outputImage
        //return the image
        return  UIImage(ciImage: self.qrCodeImage)
    }
    //creates the image and sets it to the imageView
    func displayQRCodeImage(){
        //set the scales
        let scaleX = qrCodeView.frame.size.width / qrCodeImage.extent.size.width
        let scaleY = qrCodeView.frame.size.height / qrCodeImage.extent.size.height
        //tranformers
        let transformed = qrCodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        //create the image and set it to image of code view
        qrCodeView.image = UIImage(ciImage: transformed)
    }
}
