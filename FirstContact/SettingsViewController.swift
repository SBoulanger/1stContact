//
//  File.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 10/19/16.
//  Copyright © 2016 Samuel Boulanger. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    
    var tableValues = ["me","Scanned Contacts","Address Book","Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
    }
    @IBAction func exitPressed(_ sender: Any) { self.dismiss(animated: true, completion: nil)}

    @IBAction func icon8ButtonPressed(_ sender: Any) {
        if let url = URL(string: "https://icons8.com") {
            UIApplication.shared.open(url, options: [:]) {
                boolean in
                print(boolean)
            }
        }
    }
}
