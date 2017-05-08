//
//  File.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 10/19/16.
//  Copyright © 2016 Samuel Boulanger. All rights reserved.
//

import Foundation
import UIKit
import AWSCognitoIdentityProvider
import AWSMobileHubHelper
import AWSCognitoUserPoolsSignIn

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var settingsPicker: UIPickerView!
    
    @IBOutlet weak var goButton: UIButton!
    var settingsValues = ["change password","delete account","acknowledgments"]
    var settingsOn = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsOn = settingsValues[0]
        self.goButton.layer.cornerRadius = 3.5
        self.settingsPicker.delegate = self
        self.settingsPicker.dataSource = self
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.green
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    @IBAction func exitPressed(_ sender: Any) { self.dismiss(animated: true, completion: nil)}

    @IBAction func goButtonPressed(_ sender: Any) {
        
        if (settingsOn == "acknowledgments" || AWSSignInManager.sharedInstance().isLoggedIn){
            self.performSegue(withIdentifier: settingsOn, sender: self)
        } else {
            let alerter = UIAlertController(title: "📵", message: "You are not logged in", preferredStyle:  UIAlertControllerStyle.alert)
            let dismissHandler = {(action:UIAlertAction!) -> Void in
                print("ok")
            }
            let dismissAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: dismissHandler)
            alerter.addAction(dismissAction)
            present(alerter, animated: true, completion: nil)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return self.settingsPicker.frame.width
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return settingsValues[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.settingsOn = settingsValues[row]
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return settingsValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attr = [NSFontAttributeName: UIFont(name: "KohinoorBangla-Light", size: 17)!]
        let attributeString = NSAttributedString(string: settingsValues[row],attributes:attr)
        return attributeString
        
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var view = UIView(frame: CGRect(x: 0, y: 0, width: self.settingsPicker.frame.width, height: 30))
        let label = UILabel(frame:CGRect(x: 0, y: 0, width: self.settingsPicker.frame.width, height: 30))
        view.addSubview(label)
        label.text = settingsValues[row]
        return view
    }

}
