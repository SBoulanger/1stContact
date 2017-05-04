//
//  LinkedInWebView.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 5/3/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import WebKit
import UIKit

let linkedInKey = "86tp0696zhckjv"
let linkedInSecret = "dfgJhwunGSVi0FJX"
let authorizationEndPoint = "https://www.linkedin.com/uas/oauth2/authorization"
let accessTokenEndPoint =   "https://www.linkedin.com/uas/oauth2/accessToken"

class LinkedInWebView : UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var exitButton: UIBarButtonItem!
    
    var dataHub : DataHub!
    var lidelegate : LinkedinCardCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startAuthorization()
        self.dataHub = AppDelegate.getAppDelegate().dataHub
        self.webView.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        exitButton.imageInsets = UIEdgeInsetsMake(10.0, 0.0, 10.0, 20.0)
        print("LinkedInWebView")
    }
    func startAuthorization() {
        print("LinkedInWebView: startAuthorization")
        // Specify the response type which should always be "code".
        let responseType = "code"
        
        // Set the redirect URL. Adding the percent escape characthers is necessary.
        let redirectURL : String = "https://1stcontactsite.wordpress.com".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)!
            //.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        
        // Create a random string based on the time interval (it will be in the form linkedin12345679).
        let state = "linkedin\(Int(NSDate().timeIntervalSince1970))"
        
        // Set preferred scope.
        let scope = "r_basicprofile"
        
        // Create the authorization URL string.
        var authorizationURL = "\(authorizationEndPoint)?"
        authorizationURL += "response_type=\(responseType)&"
        authorizationURL += "client_id=\(linkedInKey)&"
        authorizationURL += "redirect_uri=\(redirectURL)&"
        authorizationURL += "state=\(state)&"
        authorizationURL += "scope=\(scope)"
        
        print(authorizationURL)
        
        //let request = URLRequest(URL: URL(string: authorizationURL)!)
        let request = URLRequest(url: URL(string:authorizationURL)!)
        webView.loadRequest(request)
        
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("LinkedinWebView: Webview()")
        let url = request.url!
        
        if url.host == "1stcontactsite.wordpress.com" {
            if url.absoluteString.range(of: "code") != nil {
                // Extract the authorization code.
                let urlParts = url.absoluteString.components(separatedBy: "?")
                let code = urlParts[1].components(separatedBy: "=")[1]
                
                requestForAccessToken(authorizationCode: code)
            }
        }
        return true
    }
    func requestForAccessToken(authorizationCode: String) {
        print("LinkedinWebView: requestForAccessToken")

        let grantType = "authorization_code"
        
        let redirectURL = "https://1stcontactsite.wordpress.com".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)!
        
        // Set the POST parameters.
        var postParams = "grant_type=\(grantType)&"
        postParams += "code=\(authorizationCode)&"
        postParams += "redirect_uri=\(redirectURL)&"
        postParams += "client_id=\(linkedInKey)&"
        postParams += "client_secret=\(linkedInSecret)"
        
        // Convert the POST parameters into a NSData object.
        let postData = postParams.data(using: String.Encoding.utf8)
        
        // Initialize a mutable URL request object using the access token endpoint URL string.
        let request = NSMutableURLRequest(url: URL(string: accessTokenEndPoint)!)
        
        // Indicate that we're about to make a POST request.
        request.httpMethod = "POST"
        
        // Set the HTTP body using the postData object created above.
        request.httpBody = postData
        
        // Add the required HTTP header field.
        request.addValue("application/x-www-form-urlencoded;", forHTTPHeaderField: "Content-Type")
        
        // Initialize a NSURLSession object.
        let session = URLSession(configuration: URLSessionConfiguration.default)
        print("make the request")
        // Make the request.
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            // Get the HTTP status code of the request.
            let statusCode = (response as! HTTPURLResponse).statusCode
            print("status Code :\(statusCode)")
            if statusCode == 200 {
                // Convert the received JSON data into a dictionary.
                do {
                    print("in do block")
                    let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: Any]
                    
                    let accessToken = dataDictionary["access_token"] as! String
                    
                    UserDefaults.standard.set(accessToken, forKey: "LIAccessToken")
                    UserDefaults.standard.synchronize()
                    
                    self.getProfileInfo()
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.lidelegate.loginSucces = true
                        self.lidelegate.viewdone()
                        self.dismiss(animated: true, completion: nil)
                    })
                }
                catch {
                    print("Could not convert JSON data into a dictionary.")
                }
            }
        }
        
        task.resume()
        
    }
    func checkForExistingAccessToken() {
        print("LinkedinWebView:checkForExistingAccessToken()")
        if UserDefaults.standard.object(forKey: "LIAccessToken") != nil {
            //btnSignIn.enabled = false
            //btnGetProfileInfo.enabled = true
        }
    }
    
    func getProfileInfo(){
        print("LinkedinWebView: getProfileInfo()")
        if let accessToken = UserDefaults.standard.object(forKey: "LIAccessToken") {
            // Specify the URL string that we'll get the profile info from.
            let targetURLString = "https://api.linkedin.com/v1/people/~:(public-profile-url)?format=json"
            
            // Initialize a mutable URL request object.
            let request = NSMutableURLRequest(url: URL(string: targetURLString)!)
            
            // Indicate that this is a GET request.
            request.httpMethod = "GET"
            
            // Add the access token as an HTTP header field.
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            // Initialize a NSURLSession object.
            let session = URLSession(configuration: URLSessionConfiguration.default)
            
            // Make the request.
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                // Get the HTTP status code of the request.
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("status Code :\(statusCode)")
                if statusCode == 200 {
                    // Convert the received JSON data into a dictionary.
                    do {
                        let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                        
                        let profileURLString = dataDictionary["publicProfileUrl"] as! String
                        print(profileURLString)
                        let range = profileURLString.range(of: "https://www.linkedin.com/")
                        if (range != nil) {
                            let userData = profileURLString.substring(from: (range?.upperBound)!)
                            print(userData)
                            var contact = self.dataHub.getContact()
                            contact.linkedin = userData
                            self.dataHub.updateContact(contact: contact)
                        }

                        DispatchQueue.main.async(execute: { () -> Void in
                            //self.btnOpenProfile.setTitle(profileURLString, forState: UIControlState.Normal)
                            //self.btnOpenProfile.hidden = false
                            
                        })
                        
                    }
                    catch {
                        print("Could not convert JSON data into a dictionary.")
                    }
                }
            }
            
            task.resume()
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        lidelegate.loginSucces = false
        lidelegate.viewdone()
        self.dismiss(animated: true, completion: nil)
    }
    
}
