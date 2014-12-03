//
//  CoolPresentationController.swift
//  LookInside
//
//  Created by Herryanto Siatono on 2/12/14.
//  Copyright (c) 2014 Demo. All rights reserved.
//

import UIKit

class CoolPresentationController: UIPresentationController {
    var bigFlowerImageView: UIImageView!
    var carlImageView: UIImageView!
    
    var jaguarPrintImageH: UIImage!
    var jaguarPrintImageV: UIImage!
    
    var topJaguarPrintImageView: UIImageView!
    var bottomJaguarPrintImageView: UIImageView!
    var leftJaguarPrintImageView: UIImageView!
    var rightJaguarPrintImageView: UIImageView!
    
    var dimmingView: UIView!

    override init(presentedViewController: UIViewController!, presentingViewController: UIViewController!) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        
        self.setupViews()
    }
    
    override func containerViewWillLayoutSubviews() {
        self.dimmingView.frame = self.containerView.bounds
        self.presentedView().frame = self.frameOfPresentedViewInContainerView()
        self.moveJaguarPrintToPresentedPosition(true)
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        // Return frame that is centered in the display, with a width of 300pt and 
        // height which varies based on our vertical size class
        let containerBounds = self.containerView.bounds
        let width:CGFloat = 300
        let height = self.frameHeight(containerBounds)
        var presentedViewFrame = CGRectZero

        presentedViewFrame.size = CGSizeMake(width, height)
        presentedViewFrame.origin = CGPointMake(containerBounds.size.width / 2.0, containerBounds.size.height / 2.0)
        presentedViewFrame.origin.x -= presentedViewFrame.size.width / 2.0
        presentedViewFrame.origin.y -= presentedViewFrame.size.height / 2.0
        
        return presentedViewFrame
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        // Add chromes to dimming views
        self.addViewsToDimmingView()
        self.containerView.addSubview(self.dimmingView)
        
        // Before presentation begins, set dimming view to be transparent
        self.dimmingView.alpha = 0.0
        
        // Fade in dimming view alongside current transition
        if let transitionCoordinator = self.presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({
                (context: UIViewControllerTransitionCoordinatorContext!) in
                self.dimmingView.alpha = 1.0
            }, completion: nil)
        }
        
        // Animage jaguar print
        self.moveJaguarPrintToPresentedPosition(false)
        
        UIView.animateWithDuration(1.0, animations: {
            self.moveJaguarPrintToPresentedPosition(true)
        })
    }
    
    // MARK: Helper Methods
    
    func setupViews() {
        // Create dimming view
        self.dimmingView = UIView()
        self.dimmingView.backgroundColor = UIColor.purpleColor().colorWithAlphaComponent(0.4)
        
        // Create other chromes
        self.bigFlowerImageView = UIImageView(image: UIImage(named: "BigFlower"))
        self.carlImageView = UIImageView(image: UIImage(named: "Carl"))
        self.carlImageView.frame = CGRectMake(0, 0, 500, 245)
        
        self.jaguarPrintImageH = UIImage(named: "JaguarH")?.resizableImageWithCapInsets(UIEdgeInsetsZero, resizingMode: UIImageResizingMode.Tile)
        self.jaguarPrintImageV = UIImage(named: "JaguarV")?.resizableImageWithCapInsets(UIEdgeInsetsZero, resizingMode: UIImageResizingMode.Tile)
        
        self.topJaguarPrintImageView = UIImageView(image: self.jaguarPrintImageH)
        self.bottomJaguarPrintImageView = UIImageView(image: self.jaguarPrintImageH)
        self.leftJaguarPrintImageView = UIImageView(image: self.jaguarPrintImageV)
        self.rightJaguarPrintImageView = UIImageView(image: self.jaguarPrintImageV)
        
        self.leftJaguarPrintImageView.backgroundColor = UIColor.blueColor()
        self.rightJaguarPrintImageView.backgroundColor = UIColor.blueColor()
    }
    
    func frameHeight(containerBounds: CGRect) -> CGFloat {
        var height:CGFloat!
        
        if self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
            height = 300
        } else {
            height = containerBounds.size.height - (2 * self.jaguarPrintImageH.size.height)
        }
        
        return height
    }
    
    func addViewsToDimmingView() {
        let traitLocation = self.traitCollection
        
        // For iPad
        if traitCollection.horizontalSizeClass == .Regular &&
            traitLocation.verticalSizeClass == .Regular {
                self.dimmingView.addSubview(self.bigFlowerImageView)
                self.dimmingView.addSubview(self.carlImageView)
        }
        
        self.dimmingView.addSubview(self.topJaguarPrintImageView)
        self.dimmingView.addSubview(self.bottomJaguarPrintImageView)
        self.dimmingView.addSubview(self.leftJaguarPrintImageView)
        self.dimmingView.addSubview(self.rightJaguarPrintImageView)
    }
    
    func moveJaguarPrintToPresentedPosition(isMoveToPresentedPosition: Bool) {
        let hJaguarSize = self.jaguarPrintImageH.size
        let vJaguarSize = self.jaguarPrintImageV.size
        let presentedFrame = self.frameOfPresentedViewInContainerView()
        let containerFrame = self.containerView.frame
        
        var topFrame = CGRectZero
        var bottomFrame = CGRectZero
        var leftFrame = CGRectZero
        var rightFrame = CGRectZero
        
        topFrame.size.height = hJaguarSize.height
        topFrame.size.width = presentedFrame.size.width
        topFrame.origin.x = presentedFrame.origin.x

        bottomFrame.size.height = hJaguarSize.height
        bottomFrame.size.width = presentedFrame.size.width
        bottomFrame.origin.x = presentedFrame.origin.x
        
        leftFrame.size.width = vJaguarSize.width
        leftFrame.size.height = presentedFrame.size.height
        leftFrame.origin.y = presentedFrame.origin.y
        
        rightFrame.size.width = vJaguarSize.width
        rightFrame.size.height = presentedFrame.size.height
        rightFrame.origin.y = presentedFrame.origin.y
        
        let frameToAlign = isMoveToPresentedPosition ? presentedFrame : containerFrame
        
        topFrame.origin.y = CGRectGetMinY(frameToAlign) - hJaguarSize.height
        bottomFrame.origin.y = CGRectGetMaxY(frameToAlign)
        leftFrame.origin.x = CGRectGetMinX(frameToAlign) - vJaguarSize.width
        rightFrame.origin.x = CGRectGetMaxX(frameToAlign)
        
        self.topJaguarPrintImageView.frame = topFrame
        self.bottomJaguarPrintImageView.frame = bottomFrame
        self.leftJaguarPrintImageView.frame = leftFrame
        self.rightJaguarPrintImageView.frame = rightFrame
    }
}
