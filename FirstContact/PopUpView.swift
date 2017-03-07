//
//  popUpView.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 7/4/16.
//  Copyright © 2016 Samuel Boulanger. All rights reserved.
//


//Why is there a blue ring at the circumfrance of my exit button?


import Foundation
import UIKit

class PopUpView : UIView {
    
    var viewOffSetX = 20
    var viewOffSetY = 20
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        var frameRect = frame
        print(frame)
        frameRect.size.height = frame.height - 40
        frameRect.size.width = frame.width - 40
        frameRect.origin.x = 20
        frameRect.origin.y = 20
        print(frameRect)
        self.frame = frameRect
        self.layer.cornerRadius = 10
        
        //self.layer.frame.offsetInPlace(dx: CGFloat(viewOffSetX), dy: CGFloat(viewOffSetY))
        self.backgroundColor = UIColor.lightGray
        self.alpha = 0.95
        
        var exitButtonXPos = self.layer.frame.width - CGFloat(viewOffSetX) - CGFloat(30)
        var exitButtonYPos = CGFloat(5)

        
        var backBookmarkButton = UIButton()
        backBookmarkButton.frame = CGRect(x: exitButtonXPos, y: exitButtonYPos, width: CGFloat(40), height: CGFloat(40))
        var image = UIImage(named: "XExitButtonImage") as UIImage?
        var image_press = UIImage(named: "XExitButtonImage_press") as UIImage?
        backBookmarkButton.setImage(image, for: UIControlState())
        backBookmarkButton.setImage(image_press, for: .highlighted)
        backBookmarkButton.addTarget(self, action:#selector(exit(_:)), for: UIControlEvents.touchUpInside)
        backBookmarkButton.backgroundColor = UIColor.gray
        backBookmarkButton.layer.cornerRadius = 0.5 * backBookmarkButton.bounds.width
        
        var button = UIButton()
        var buttonframe = frame
        buttonframe.size.height = 55
        buttonframe.size.width = frame.width - 50
        button.frame = buttonframe
        button.titleLabel!.text = "button"
        self.layer.frame.offsetBy(dx: CGFloat( viewOffSetX + 5), dy: CGFloat(viewOffSetY + 15) )
        
        
        
        
        
        self.addSubview(backBookmarkButton)
        self.bringSubview(toFront: backBookmarkButton)
        
        self.addSubview(button)
        self.bringSubview(toFront: button)
        
        
    }
    
    func exit(_ sender: AnyObject){
        self.isHidden = true
    }
    
    
}
