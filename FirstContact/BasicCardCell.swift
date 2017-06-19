//
//  BasicCardCell.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 3/10/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import UIKit
import MMCardView

class BasicCardCell: CardCell, CardCellProtocol {
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    public static func cellIdentifier() -> String {
        return "BasicCard"
    }
    
    override func awakeFromNib() {
        self.layer.shadowRadius = 2.0
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.cornerRadius = 8.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1.0
        self.backgroundColor = UIColor.white
        super.awakeFromNib()
    }
    
}
