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

class QRViewController: UIViewController  {
    
    //qrcode image
    var qrCodeImage: CIImage!
    //qrcode view
    @IBOutlet weak var qrCodeView: UIImageView!
    //contact info
    var dataHub: DataHub!
    var contact: FCContact!
    var phoneNumber: String!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "FC_logo_white.png")
        let newim = ResizeImage(logo!, targetSize: CGSize(width: 50,height: 45))
        let imageView = UIImageView(image:newim)
        self.navigationItem.titleView = imageView
        
        self.dataHub =  AppDelegate.getAppDelegate().dataHub
        
        print("QRViewController viewDidLoad() entered...")
        
        self.contact = self.dataHub.getContact()
        
        //if the qrcode has not been loaded yet
        if qrCodeImage == nil {
            print("qrCodeImage NIL")
            generateNewImage()
        }
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
