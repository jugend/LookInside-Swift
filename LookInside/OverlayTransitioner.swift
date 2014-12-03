//
//  OverlayTransitioner.swift
//  LookInside
//
//  Created by Herryanto Siatono on 2/12/14.
//  Copyright (c) 2014 Demo. All rights reserved.
//

import UIKit

class OverlayTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        return OverlayPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return self.animationControllerForPresentation(true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return self.animationControllerForPresentation(false)
    }
    
    // MARK: Helper Method
    
    func animationControllerForPresentation(isPresentation: Bool) -> OverlayAnimatedTransitioning  {
        
        let animationController = OverlayAnimatedTransitioning()
        animationController.isPresentation = isPresentation
        
        return animationController
    }
}


class OverlayAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresentation = false
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // Set to and from view controllers
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromView = fromViewController.view
        let toView = toViewController.view
        
        // Add view to container view if required
        let containerView = transitionContext.containerView()
        if self.isPresentation {
            containerView.addSubview(toView)
        }
        
        // Set animating view
        let animatingViewController = self.isPresentation ? toViewController : fromViewController
        let animatingView = animatingViewController.view

        // Set the initial and final frames
        // Dismissed frame is the same with the appeared frame, but off
        // the right edge of the container
        let appearedFrame = transitionContext.finalFrameForViewController(animatingViewController)
        var dismissedFrame = appearedFrame
        dismissedFrame.origin.x += dismissedFrame.size.width
        let initialFrame = self.isPresentation ? dismissedFrame : appearedFrame
        let finalFrame = self.isPresentation ? appearedFrame : dismissedFrame
        
        // Animate view
        animatingView.frame = initialFrame
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0,
            usingSpringWithDamping: 300.0,
            initialSpringVelocity: 5.0,
            options: .AllowUserInteraction | .BeginFromCurrentState,
            animations: {
                animatingView.frame = finalFrame
            },
            completion: { (finished: Bool) in
                // If dismiss, remove the presented view from view hierarchy
                if !self.isPresentation {
                    fromView.removeFromSuperview()
                }
                
                // Notify view controller that the transition has finished
                transitionContext.completeTransition(true)
            }
        )
    }
}
    
    
