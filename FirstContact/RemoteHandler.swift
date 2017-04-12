//
//  RemoteHandler.swift
//  FirstContact
//
//  Created by Samuel Boulanger on 3/27/17.
//  Copyright © 2017 Samuel Boulanger. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import UIKit

import ObjectiveC

class RemoteHandler : UIViewController{
    
    fileprivate var manager: AWSUserFileManager!
    fileprivate var contents: [AWSContent]?
    fileprivate var didLoadAllContents: Bool!
    fileprivate var marker: String?
    
    var prefix: String!
    
    override func viewDidLoad() {
        manager = AWSUserFileManager.defaultUserFileManager()
        didLoadAllContents = false
        print("RemoteHandler instance created")
        if (AWSIdentityManager.default().isLoggedIn) {
            let userId = AWSIdentityManager.default().identityId!
            prefix = "\(UserFilesPrivateDirectoryName)/\(userId)/"
            refreshContents()
            //updateUserInterface()
            loadMoreContents()
            //downloadContact()
            print("asldkfhklajshdf;lkjas;ldkjf;lkasjdf;lkjsadkk ===========\n\n\n\n\n\n\n\n\n\\n")
        }
        
    }
    
    fileprivate func refreshContents() {
        marker = nil
        loadMoreContents()
    }
    
    fileprivate func downloadContact(){
        print("download Contact")
        /*var end = contents?.count
            print("recent")
            contents?.forEach({ (content: AWSContent) in
                print("CONTENT")
                print(content)
                if !content.isCached && !content.isDirectory {
                    content.download(with: .ifNewerExists, pinOnCompletion: false, progressBlock: nil, completionHandler: {[weak self] (content: AWSContent?, data: Data?, error:Error?) in
                        
                        if (content?.key.range(of: ".json") != nil){
                            print("HEHEHEHHEHEHEHEHEHHEH;fldja;lf jl;djfl;kja;f")
                            var cont = FCContact()
                            cont.encodeJSON(data: data!)
                            print("WOKRED")
                        }
                    })
                }
        })*/
    }
    
    fileprivate func loadMoreContents() {
        print("LOAD MORE CONTENT ENTERED")
        /*let uploadsDirectory = "\(UserFilesUploadsDirectoryName)/"
        if prefix == uploadsDirectory {
            updateUserInterface()
            return
        }*/
        print(prefix)
        print(marker)
        manager.listAvailableContents(withPrefix: prefix, marker: marker) {[weak self] (contents: [AWSContent]?, nextMarker: String?, error: Error?) in
            guard let strongSelf = self else { return }
            if let error = error {
                //strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to load the list of contents.", cancelButtonTitle: "OK")
                print("Failed to load the list of contents. \(error)")
            }
            if let contents = contents, contents.count > 0 {
                strongSelf.contents = contents

                print("-------------------------------------------------------------------------------")
                print("-----------------------------------CONTENT-------------------------------------")
                print("-------------------------------------------------------------------------------")
                print(contents)
                strongSelf.downloadContact()
                print("-------------------------------------------------------------------------------")
                print("-------------------------------------------------------------------------------")
                print("-------------------------------------------------------------------------------")
                if let nextMarker = nextMarker, !nextMarker.isEmpty {
                    strongSelf.didLoadAllContents = false
                } else {
                    strongSelf.didLoadAllContents = true
                }
                strongSelf.marker = nextMarker
            } else {
                print("else")
                //strongSelf.checkUserProtectedFolder()
            }
            //strongSelf.downloadContact()
            //strongSelf.updateUserInterface()
        }
        print("listAvailableContents done")
        /*manager.listAvailableContents(withPrefix: prefix, marker: marker) {[weak self] (contents: [AWSContent]?, nextMarker: String?, error: Error?) in
            print("listAvailableContents entered")
            guard let strongSelf = self else { print("premature return"); return }
            print("strongSelf init")
            if let error = error {
                //strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to load the list of contents.", cancelButtonTitle: "OK")
                print("-------------------------------------------------------------------------------")
                print("-----------------------------------ERROR-CONTENT-------------------------------")
                print("-------------------------------------------------------------------------------")

                print("Failed to load the list of contents. \(error)")
            }
            if let contents = contents, contents.count > 0 {
                print("contents count > 0 and contents = contents")
                strongSelf.contents = contents
                //contents[0].download(with: .ifNewerExists, pinOnCompletion: false, progressBlock: nil, completionHandler: {[weak self] (content: AWSContent?,data: Data?, error: Error?) in
                //})
                print("-------------------------------------------------------------------------------")
                print("-----------------------------------CONTENT-------------------------------------")
                print("-------------------------------------------------------------------------------")
                print(contents)
                print("-------------------------------------------------------------------------------")
                print("-------------------------------------------------------------------------------")
                print("-------------------------------------------------------------------------------")
                
                if let nextMarker = nextMarker, !nextMarker.isEmpty {
                    strongSelf.didLoadAllContents = false
                    print("Did load all contents false")
                } else {
                    strongSelf.didLoadAllContents = true
                    print("did load all contents true")
                }
                strongSelf.marker = nextMarker
            } else {
                print("check user protected folder")
                //strongSelf.checkUserProtectedFolder()
            }
            print("listAvailableContents end")
            //strongSelf.updateUserInterface()
        }*/
        
        
        
        
        
        print("loadMoreContents end")
    }
    

    
    fileprivate func downloadContent(_ content: AWSContent, pinOnCompletion: Bool) {
        content.download(with: .ifNewerExists, pinOnCompletion: pinOnCompletion, progressBlock: {[weak self] (content: AWSContent, progress: Progress) in
            guard let strongSelf = self else { return }
            if strongSelf.contents!.contains( where: {$0 == content} ) {
               // strongSelf.tableView.reloadData()
            }
        }) {[weak self] (content: AWSContent?, data: Data?, error: Error?) in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Failed to download a content from a server. \(error)")
                //strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to download a content from a server.", cancelButtonTitle: "OK")
            }
            strongSelf.updateUserInterface()
        }
    }
    public func uploadWithData(data: NSData, forKey key: String) {
        let manager = AWSUserFileManager.defaultUserFileManager()
        let localContent = manager.localContent(with: data as Data, key: prefix + key)
        localContent.uploadWithPin(
            onCompletion: false,
            progressBlock: {[weak self](content: AWSLocalContent, progress: Progress) -> Void in
                guard let strongSelf = self else { return }
                /* Show progress in UI. */
            },
            completionHandler: {[weak self](content: AWSLocalContent?, error: Error?) -> Void in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("Failed to upload an object. \(error)")
                } else {
                    print("Object upload complete. \(error)")
                }
        })
    }
    fileprivate func updateUserInterface() {
        DispatchQueue.main.async {
            if let prefix = self.prefix {
                var pathText = "\(prefix)"
                var startFrom = prefix.startIndex
                var offset = 0
                let maxPathTextLength = 50
                
                //if prefix.hasPrefix(UserFilesPublicDirectoryName) {
                //    startFrom = UserFilesPublicDirectoryName.endIndex
                //} else if prefix.hasPrefix(UserFilesPrivateDirectoryName) {
                    let userId = AWSIdentityManager.default().identityId!
                    startFrom = UserFilesPrivateDirectoryName.endIndex
                    offset = userId.characters.count + 1
                //} else if prefix.hasPrefix(UserFilesProtectedDirectoryName) {
                //    startFrom = UserFilesProtectedDirectoryName.endIndex
                //} else if prefix.hasPrefix(UserFilesUploadsDirectoryName) {
                //    startFrom = UserFilesUploadsDirectoryName.endIndex
                //}
                
                startFrom = prefix.characters.index(startFrom, offsetBy: offset + 1)
                pathText = "\(prefix.substring(from: startFrom))"
                
                if pathText.characters.count > maxPathTextLength {
                    pathText = "...\(pathText.substring(from: pathText.characters.index(pathText.endIndex, offsetBy: -maxPathTextLength)))"
                }
                //self.pathLabel.text = "\(pathText)"
            //} else {
            //    self.pathLabel.text = "/"
            //}
            //self.segmentedControl.selectedSegmentIndex = self.segmentedControlSelected
            //self.tableView.reloadData()
        }
    }
    }

    /*
    fileprivate func openContent(_ content: AWSContent) {
        if content.isAudioVideo() { // Video and sound files
            let directories: [AnyObject] = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [AnyObject]
            let cacheDirectoryPath = directories.first as! String
            
            let movieURL: URL = URL(fileURLWithPath: "\(cacheDirectoryPath)/\(content.key.getLastPathComponent())")
            
            try? content.cachedData.write(to: movieURL, options: [.atomic])
            
            let controller: MPMoviePlayerViewController = MPMoviePlayerViewController(contentURL: movieURL)
            controller.moviePlayer.prepareToPlay()
            controller.moviePlayer.play()
            presentMoviePlayerViewControllerAnimated(controller)
        } else if content.isImage() { // Image files
            // Image files
            let storyboard = UIStoryboard(name: "UserFiles", bundle: nil)
            let imageViewController = storyboard.instantiateViewController(withIdentifier: "UserFilesImageViewController") as! UserFilesImageViewController
            imageViewController.image = UIImage(data: content.cachedData)
            imageViewController.title = content.key
            navigationController?.pushViewController(imageViewController, animated: true)
        } else {
            showSimpleAlertWithTitle("Sorry!", message: "We can only open image, video, and sound files.", cancelButtonTitle: "OK")
        }
    }*/
    /*
    fileprivate func openRemoteContent(_ content: AWSContent) {
        content.getRemoteFileURL {[weak self] (url: URL?, error: Error?) in
            guard let strongSelf = self else { return }
            guard let url = url else {
                print("Error getting URL for file. \(error)")
                return
            }
            if content.isAudioVideo() { // Open Audio and Video files natively in app.
                let controller: MPMoviePlayerViewController = MPMoviePlayerViewController(contentURL: url)
                controller.moviePlayer.prepareToPlay()
                controller.moviePlayer.play()
                strongSelf.presentMoviePlayerViewControllerAnimated(controller)
            } else { // Open other file types like PDF in web browser.
                //UIApplication.sharedApplication().openURL(url)
                let storyboard: UIStoryboard = UIStoryboard(name: "UserFiles", bundle: nil)
                let webViewController: UserFilesWebViewController = storyboard.instantiateViewController(withIdentifier: "UserFilesWebViewController") as! UserFilesWebViewController
                webViewController.url = url
                webViewController.title = content.key
                strongSelf.navigationController?.pushViewController(webViewController, animated: true)
            }
        }
    }
    */
    fileprivate func confirmForRemovingContent(_ content: AWSContent) {
        let alertController = UIAlertController(title: "Confirm", message: "Do you want to delete the content from the server? This cannot be undone.", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Yes", style: .default) {[weak self] (action: UIAlertAction) in
            guard let strongSelf = self else { return }
            strongSelf.removeContent(content)
        }
        alertController.addAction(okayAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        //present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func removeContent(_ content: AWSContent) {
        content.removeRemoteContent {[weak self] (content: AWSContent?, error: Error?) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to delete an object from the remote server. \(error)")
                    //strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to delete an object from the remote server.", cancelButtonTitle: "OK")
                } else {
                    //strongSelf.showSimpleAlertWithTitle("Object Deleted", message: "The object has been deleted successfully.", cancelButtonTitle: "OK")
                    strongSelf.refreshContents()
                }
            }
        }
    }
    // MARK:- Content user action methods
    
    fileprivate func showActionOptionsForContent(_ rect: CGRect, content: AWSContent) {
        /*
         let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
         if alertController.popoverPresentationController != nil {
         //alertController.popoverPresentationController?.sourceView = self.view
         alertController.popoverPresentationController?.sourceRect = CGRect(x: rect.midX, y: rect.midY, width: 1.0, height: 1.0)
         }
         if content.isCached {
         let openAction = UIAlertAction(title: "Open", style: .default, handler: {(action: UIAlertAction) -> Void in
         DispatchQueue.main.async {
         self.openContent(content)
         }
         })
         alertController.addAction(openAction)
         }*/
        /*
         // Allow opening of remote files natively or in browser based on their type.
         let openRemoteAction = UIAlertAction(title: "Open Remote", style: .default, handler: {[unowned self](action: UIAlertAction) -> Void in
         self.openRemoteContent(content)
         
         })
         alertController.addAction(openRemoteAction)
         */
        // If the content hasn't been downloaded, and it's larger than the limit of the cache,
        // we don't allow downloading the contentn.
        if content.knownRemoteByteCount + 4 * 1024 < self.manager.maxCacheSize {
            // 4 KB is for local metadata.
            var title = "Download"
            
            if let downloadedDate = content.downloadedDate, let knownRemoteLastModifiedDate = content.knownRemoteLastModifiedDate, knownRemoteLastModifiedDate.compare(downloadedDate) == .orderedDescending {
                title = "Download Latest Version"
            }
            let downloadAction = UIAlertAction(title: title, style: .default, handler: {[unowned self](action: UIAlertAction) -> Void in
                self.downloadContent(content, pinOnCompletion: false)
            })
            // alertController.addAction(downloadAction)
        }
        let downloadAndPinAction = UIAlertAction(title: "Download & Pin", style: .default, handler: {[unowned self](action: UIAlertAction) -> Void in
            self.downloadContent(content, pinOnCompletion: true)
        })
        // alertController.addAction(downloadAndPinAction)
        if content.isCached {
            if content.isPinned {
                let unpinAction = UIAlertAction(title: "Unpin", style: .default, handler: {[unowned self](action: UIAlertAction) -> Void in
                    content.unPin()
                    //self.updateUserInterface()
                })
                //   alertController.addAction(unpinAction)
            } else {
                let pinAction = UIAlertAction(title: "Pin", style: .default, handler: {[unowned self](action: UIAlertAction) -> Void in
                    content.pin()
                    //  self.updateUserInterface()
                })
                //  alertController.addAction(pinAction)
            }
            let removeAction = UIAlertAction(title: "Delete Local Copy", style: .destructive, handler: {[unowned self](action: UIAlertAction) -> Void in
                content.removeLocal()
                //self.updateUserInterface()
            })
            // alertController.addAction(removeAction)
        }
        
        let removeFromRemoteAction = UIAlertAction(title: "Delete Remote File", style: .destructive, handler: {[unowned self](action: UIAlertAction) -> Void in
            self.confirmForRemovingContent(content)
        })
        
        // alertController.addAction(removeFromRemoteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        //  alertController.addAction(cancelAction)
        
        //present(alertController, animated: true, completion: nil)
    }
}
// MARK: - Utility
/*
extension RemoteHandler {
    fileprivate func showSimpleAlertWithTitle(_ title: String, message: String, cancelButtonTitle cancelTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func checkUserProtectedFolder() {
        let userId = AWSIdentityManager.default().identityId!
        if isPrefixUserProtectedFolder() {
            let localContent = self.manager.localContent(with: nil, key: "\(UserFilesProtectedDirectoryName)/\(userId)/")
            localContent.uploadWithPin(onCompletion: false, progressBlock: {(content: AWSLocalContent?, progress: Progress?) in
            }, completionHandler: {[weak self](content: AWSContent?, error: Error?) in
                guard let strongSelf = self else { return }
                strongSelf.updateUploadUI()
                if let error = error {
                    print("Failed to load the list of contents. \(error)")
                    strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to load the list of contents.", cancelButtonTitle: "OK")
                }
                strongSelf.updateUserInterface()
            })
        }
    }
    
    fileprivate func isPrefixUserProtectedFolder() -> Bool {
        let userId = AWSIdentityManager.default().identityId!
        let protectedUserDirectory = "\(UserFilesProtectedDirectoryName)/\(userId)/"
        return AWSIdentityManager.default().isLoggedIn && protectedUserDirectory == prefix
    }
    
    fileprivate func isPrefixUploadsFolder() -> Bool {
        let uploadsDirectory = "\(UserFilesUploadsDirectoryName)/"
        return uploadsDirectory == prefix
    }
}
 */
