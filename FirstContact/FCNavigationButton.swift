//
//  1CNavigationButton.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 3/6/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import UIKit

class FCNavigationButton : UIButton {
    static var SIZE = 100
    
    required init(x: Int, y:Int, image: UIImage){
        
        let frame = CGRect(x: x, y: y, width: FCNavigationButton.SIZE, height: FCNavigationButton.SIZE)
        super.init(frame: frame)
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        //self.clipsToBounds = true
        self.backgroundColor = UIColor.white
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 2.0
        self.setImage(image, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUpRightButton(){
        self.layer.shadowOffset = CGSize(width: -2, height: -2)
        self.imageEdgeInsets = UIEdgeInsetsMake(17.0, 17.0, 55.0, 55.0)
        self.addTarget(nil, action: #selector(self.moveRight), for: UIControlEvents.touchUpInside)
    }
    func setUpLeftButton(){
        self.layer.shadowOffset = CGSize(width: 2, height: -2)
        self.imageEdgeInsets = UIEdgeInsetsMake(17.0, 55.0, 55.0, 17.0)
        self.addTarget(nil, action: #selector(self.moveLeft), for: UIControlEvents.touchUpInside)


    }
    func moveRight(){
        AppDelegate.getAppDelegate().container.moveRight()
    }
    func moveLeft(){
        AppDelegate.getAppDelegate().container.moveLeft()
    }
    func moveDown(){
        
    }
    
}
