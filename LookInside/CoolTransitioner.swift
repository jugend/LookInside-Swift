//
//  CoolTransitioner.swift
//  LookInside
//
//  Created by Herryanto Siatono on 2/12/14.
//  Copyright (c) 2014 Demo. All rights reserved.
//

import UIKit

class CoolTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        return CoolPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return self.animationControllerForPresentation(true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return self.animationControllerForPresentation(false)
    }

    // MARK: Helper Method
    
    func animationControllerForPresentation(isPresentation: Bool) -> CoolAnimatedTransitioning  {
        
        let animationController = CoolAnimatedTransitioning()
        animationController.isPresentation = isPresentation
        
        return animationController
    }
}

class CoolAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
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
        
        // Add toView to container view if requird
        let containerView = transitionContext.containerView()
        if self.isPresentation {
            containerView.addSubview(toView)
        }
        
        // Set animating view
        let animatingViewController = self.isPresentation ? toViewController : fromViewController
        let animatingView = animatingViewController.view
        
        let appearedFrame = transitionContext.finalFrameForViewController(animatingViewController)
        animatingView.frame = appearedFrame
        
        // Set presented and dismissed trasnform
        let presentedTransform = CGAffineTransformIdentity
        let dismissedTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.001, 0.001), CGAffineTransformMakeRotation(CGFloat(8 * M_PI)))
        
        // Animate View
        animatingView.transform = isPresentation ? dismissedTransform : presentedTransform
        UIView.animateWithDuration(self.transitionDuration(transitionContext),
            delay: 0,
            usingSpringWithDamping: 300.0,
            initialSpringVelocity: 5.0,
            options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                animatingView.transform = self.isPresentation ? presentedTransform : dismissedTransform
            },
            completion: { (finished: Bool) in
                if !self.isPresentation {
                    fromView.removeFromSuperview()
                }
                
                transitionContext.completeTransition(true)
            }
        )
    }
}

