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
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let circleImage = AppDelegate.getAppDelegate().ResizeImage(UIImage(named:"CircledUp2-50.png")!, targetSize: CGSize(width: 24, height: 24))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: circleImage, style: .plain, target: self, action: #selector(showSendViewController))

        //self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsetsMake(10.0, 0.0, 10.0, 20.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logo = UIImage(named: "FC_logo_white.png")
        let newim = AppDelegate.getAppDelegate().ResizeImage(logo!, targetSize: CGSize(width: 40,height: 50))
        let camButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
        camButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        camButton.setImage(newim, for: .normal)
        
        
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: UIFont(name: "KohinoorBangla-Light", size: 23)!,
              NSForegroundColorAttributeName: UIColor.green])
        self.navigationController?.navigationBar.tintColor = UIColor.green
        
        self.navigationItem.titleView = camButton
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        camButton.addTarget(nil, action: #selector(AppDelegate.getAppDelegate().container.moveDown), for: .touchUpInside)

        self.dataHub =  AppDelegate.getAppDelegate().dataHub
        if (AWSSignInManager.sharedInstance().isLoggedIn){
            self.startSpinning()
        } else {
            self.loadingSpinner.isHidden = true
        }
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
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"CircledUp2-50.png"), style: .plain, target: self, action: #selector(showSendViewController))
        //self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsetsMake(10.0, 0.0, 10.0, 20.0)
        self.view.addSubview(rightButton)
        self.view.addSubview(leftButton)
        contact.getDefaultJSON()
        //setUpAWSContent()

    }
    
    func startSpinning() {
        loadingSpinner.isHidden = false
        AppDelegate.getAppDelegate().container.view.isUserInteractionEnabled = false
        loadingSpinner.startAnimating()
    }
    
    func stopSpinning() {
        AppDelegate.getAppDelegate().container.view.isUserInteractionEnabled = true
        loadingSpinner.stopAnimating()
        loadingSpinner.isHidden = true
    }
    func showSendViewController() {
        let sendSB = UIStoryboard(name: "SendContact", bundle: nil)
        print(sendSB)
        let sendVC = sendSB.instantiateInitialViewController()! as UIViewController
        sendVC.modalPresentationStyle = .popover
        self.navigationController?.present(sendVC, animated: true, completion: nil)
    }
    

    func generateNewImage(){
        qrCodeView.image = generateCode()
        displayQRCodeImage()
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
