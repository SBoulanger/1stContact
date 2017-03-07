//
//  InstructionViewContoller.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 10/29/15.
//  Copyright © 2015 Samuel Boulanger. All rights reserved.
//

import UIKit
//import AddressBook

class InstructionViewController: UIViewController {

    override func viewDidLoad(){
        super.viewDidLoad()
        makeCircleButton(goButton)
        self.goButton.titleLabel?.font = ButtonStyle.font
    }
    @IBAction func goButtonPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "toMain", sender: self)
    }
    @IBOutlet weak var goButton: UIButton!
    
    
    func makeCircleButton(_ button: UIButton){
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
    }

}
