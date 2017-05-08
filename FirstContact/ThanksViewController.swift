//
//  ThanksViewController.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 5/7/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import UIKit

class ThanksViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.title = "Acknowledgements"
        navigationController?.navigationBar.titleTextAttributes = ([NSFontAttributeName: UIFont(name:"KohinoorBangla-Light", size: 23)!,NSForegroundColorAttributeName: UIColor.green])
        self.navigationController?.navigationBar.barTintColor = UIColor.white

    }
    
    @IBAction func iconButtonPressed(_ sender: Any) {
        if let url = URL(string: "https://icons8.com") {
            UIApplication.shared.open(url, options: [:]) {
                boolean in
                print(boolean)
            }
        }
    }
}
