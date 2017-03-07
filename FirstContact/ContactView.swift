//
//  contactView.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 7/22/16.
//  Copyright © 2016 Samuel Boulanger. All rights reserved.
//

import Foundation
import Foundation
import UIKit

class ContactView : UIView {
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        var frameRect = frame
        frameRect.size.height = frame.height
        var viewOffSetY = frame.height
        frameRect.size.width = frame.width
        self.frame = frameRect
        self.layer.cornerRadius = 10
        self.layer.frame.offsetBy(dx: CGFloat(0), dy: CGFloat(viewOffSetY))
        self.backgroundColor = UIColor.lightGray
        self.alpha = 0.95
        
        //var exitButtonXPos = self.layer.frame.width - CGFloat(0) - CGFloat(30)
        //var exitButtonYPos = CGFloat(5)
        
        //add insta follower
        
        var instagramHooks = "instagram://user?username=johndoe"
        var instagramUrl = URL(string: instagramHooks)
        if UIApplication.shared.canOpenURL(instagramUrl!)
        {
            UIApplication.shared.openURL(instagramUrl!)
            
        } else {
            //redirect to safari because the user doesn't have Instagram
            UIApplication.shared.openURL(URL(string: "http://instagram.com/")!)
        }
        
        var snapHooks = "snapchat://add/johndoe"
        var snapchatUrl = URL(string: snapHooks)
        if UIApplication.shared.canOpenURL(snapchatUrl!)
        {
            UIApplication.shared.openURL(snapchatUrl!)
            
        } else {
            //redirect to safari because the user doesn't have Snapchat
            UIApplication.shared.openURL(URL(string: "http://snapchat.com/")!)
        }
        
        
        //var back BookmarkButton = UIButton()
        //backBookmarkButton.frame = CGRectMake(exitButtonXPos, exitButtonYPos, CGFloat(40), CGFloat(40))
        //var image = UIImage(named: "XExitButtonImage") as UIImage?
        //var image_press = UIImage(named: "XExitButtonImage_press") as UIImage?
        //backBookmarkButton.setImage(image, forState: .Normal)
        //backBookmarkButton.setImage(image_press, forState: .Highlighted)
        //backBookmarkButton.addTarget(self, action:#selector(exit(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        //backBookmarkButton.backgroundColor = UIColor.grayColor()
        //backBookmarkButton.layer.cornerRadius = 0.5 * backBookmarkButton.bounds.width
        
        //self.addSubview(backBookmarkButton)
        //  self.bringSubviewToFront(backBookmarkButton)
        
        
        
    }
    
    func exit(_ sender: AnyObject){
        self.isHidden = true
    }
    
    
}


class CustomButton: UIButton {
    var isFilled = false
}





