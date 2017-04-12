//
//  ContainerViewController.swift
//  SnapchatSwipeView
//
//  Created by Jake Spracher on 8/9/15.
//  Copyright (c) 2015 Jake Spracher. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol ContainerViewControllerDelegate {
    func outerScrollViewShouldScroll() -> Bool
}

class ContainerViewController: UIViewController, UIScrollViewDelegate {
    
    //var topVc: UIViewController?
    var leftVc: UIViewController!
    var middleVc: UIViewController!
    var rightVc: UIViewController!
    var bottomVc: UIViewController?
    
    var directionLockDisabled: Bool!
    
    var horizontalViews = [UIViewController]()
    var veritcalViews = [UIViewController]()
    
    var initialContentOffset = CGPoint() // scrollView initial offset
    var middleVertScrollVc: VerticalScrollViewController!
    var scrollView: UIScrollView!
    var delegate: ContainerViewControllerDelegate?
    var totalview = (x:CGFloat(0),y:CGFloat(0),width:CGFloat(0),height:CGFloat(0))
    
    class func containerViewWith(_ leftVC: UIViewController,
                                 middleVC: UIViewController,
                                 rightVC: UIViewController,
                                 /*topVC: UIViewController?=nil,*/
                                 bottomVC: UIViewController?=nil,
                                 directionLockDisabled: Bool?=false) -> ContainerViewController {
        let container = ContainerViewController()
        
        container.directionLockDisabled = directionLockDisabled
        
        //container.topVc = topVC
        container.leftVc = leftVC
        container.middleVc = middleVC
        container.rightVc = rightVC
        container.bottomVc = bottomVC
        return container
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVerticalScrollView()
        setupHorizontalScrollView()
    }
    
    
    
    func setupVerticalScrollView() {
        middleVertScrollVc = VerticalScrollViewController.verticalScrollVcWith(middleVc,
                                                                               /*topVc: topVc,*/
                                                                               bottomVc: bottomVc)
        delegate = middleVertScrollVc
    }
    
    func setupHorizontalScrollView() {
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.panGestureRecognizer.delaysTouchesBegan = true
        self.totalview = (
            x: self.view.bounds.origin.x,
            y: self.view.bounds.origin.y,
            width: self.view.bounds.width,
            height: self.view.bounds.height
        )
        let view = self.totalview

        scrollView.frame = CGRect(x: view.x,
                                  y: view.y,
                                  width: view.width,
                                  height: view.height
        )
        
        self.view.addSubview(scrollView)
        
        let scrollWidth  = 3 * view.width
        let scrollHeight  = view.height
        scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
        
        leftVc.view.frame = CGRect(x: 0,
                                   y: 0,
                                   width: view.width,
                                   height: view.height
        )
        
        middleVertScrollVc.view.frame = CGRect(x: view.width,
                                               y: 0,
                                               width: view.width,
                                               height: view.height
        )
        
        rightVc.view.frame = CGRect(x: 2 * view.width,
                                    y: 0,
                                    width: view.width,
                                    height: view.height
        )
        
        addChildViewController(leftVc)
        addChildViewController(middleVertScrollVc)
        addChildViewController(rightVc)
        
        scrollView.addSubview(leftVc.view)
        scrollView.addSubview(middleVertScrollVc.view)
        scrollView.addSubview(rightVc.view)
        
        leftVc.didMove(toParentViewController: self)
        middleVertScrollVc.didMove(toParentViewController: self)
        rightVc.didMove(toParentViewController: self)
        
        scrollView.contentOffset.x = middleVertScrollVc.view.frame.origin.x
        scrollView.delegate = self
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.initialContentOffset = scrollView.contentOffset
    }
    func moveRight(){
        self.scrollView.setContentOffset(CGPoint(x:self.scrollView.contentOffset.x + self.view.frame.width,y:self.scrollView.contentOffset.y), animated: true)
    }
    func moveLeft(){
        self.scrollView.setContentOffset(CGPoint(x:self.scrollView.contentOffset.x - self.view.frame.width,y:self.scrollView.contentOffset.y), animated: true)
    }
    func moveDown(){
        self.middleVertScrollVc.scrollView.setContentOffset(CGPoint(x:self.middleVertScrollVc.scrollView.contentOffset.x,y:self.middleVertScrollVc.scrollView.contentOffset.y + self.view.frame.height), animated: true)
    }
    func moveUp(){
        self.middleVertScrollVc.scrollView.setContentOffset(CGPoint(x:self.middleVertScrollVc.scrollView.contentOffset.x,y:self.middleVertScrollVc.scrollView.contentOffset.y - self.view.frame.height), animated: true)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(self.initialContentOffset.x)
        if self.initialContentOffset.x == 0.0 || self.initialContentOffset.x == 750.0 {
            //print(self.initialContentOffset)
        }
        if delegate != nil && !delegate!.outerScrollViewShouldScroll() && !directionLockDisabled {
            let newOffset = CGPoint(x: self.initialContentOffset.x, y: self.initialContentOffset.y)
            // Setting the new offset to the scrollView makes it behave like a proper
            // directional lock, that allows you to scroll in only one direction at any given time
            self.scrollView!.setContentOffset(newOffset, animated:  false)
        }
        //print(self.initialContentOffset.y)
    }
    
}
