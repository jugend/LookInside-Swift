//
//  OverlayPresentationController.swift
//  LookInside
//
//  Created by Herryanto Siatono on 2/12/14.
//  Copyright (c) 2014 Demo. All rights reserved.
//

import UIKit

class OverlayPresentationController: UIPresentationController {
    var dimmingView: UIView!
    
    // MARK: Init
    
    override init(presentedViewController: UIViewController!, presentingViewController: UIViewController!) {

        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        
        self.prepareDimmingView()
    }
    
    // MARK: Controller Methods
    override func containerViewWillLayoutSubviews() {
        // Make sure dimmingView and presentedView have the correct farme
        
        self.dimmingView.frame = self.containerView.frame
        self.presentedView().frame = self.frameOfPresentedViewInContainerView()
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        // Return a rect the same size as sizeForChildContentContainer,
        // and right aligned
        var presentedViewFrame = CGRectZero
        let containerBounds = self.containerView.bounds
        
        presentedViewFrame.size = self.sizeForChildContentContainer(self.presentedViewController, withParentContainerSize: containerBounds.size)
        
        presentedViewFrame.origin.x = containerBounds.size.width - presentedViewFrame.size.width
        
        return presentedViewFrame
    }
    
    // Called when device rotates
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        
        // Width 1/3 of parent view, height matching the parent view
        return CGSizeMake(floor(parentSize.width / 3.0), parentSize.height)
    }

    override func presentationTransitionWillBegin() {
        let containerView = self.containerView
        let presentedViewController = self.presentedViewController
        
        self.dimmingView.frame = containerView.bounds
        self.dimmingView.alpha = 0.0
        
        // Insert dimming view below everythig else
        containerView.insertSubview(self.dimmingView, atIndex: 0)
        
        // Fade in dimming view
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({
                (context:UIViewControllerTransitionCoordinatorContext!) in

                self.dimmingView.alpha = 1.0
            }, completion: nil)
        } else {
            self.dimmingView.alpha = 1.0
        }
    }
    
    override func dismissalTransitionWillBegin() {
        // Fade out the dimming view
        if let transitionCoordinator = self.presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({
                (context: UIViewControllerTransitionCoordinatorContext!) in
                
                self.dimmingView.alpha = 0.0
            }, completion: nil)
        }
    }
    
    override func adaptivePresentationStyle() -> UIModalPresentationStyle {
        // Display over full screen on compact environment
        return UIModalPresentationStyle.OverFullScreen
    }
    
    override func shouldPresentInFullscreen() -> Bool {
        // Default is true
        return true
    }
    
    // MARK: Helper Methods
    
    func prepareDimmingView() {
        self.dimmingView = UIView()
        self.dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        self.dimmingView.alpha = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "dimmingViewTapped:")
        self.dimmingView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Actions
    
    func dimmingViewTapped(gesture: UIGestureRecognizer) {
        
        // Note: that UIGestureRecognizerState.Recognized not available in Swift
        if gesture.state == UIGestureRecognizerState.Ended {
            self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}