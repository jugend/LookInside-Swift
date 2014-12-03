//
//  RootViewController.swift
//  LookInside
//
//  Created by Herryanto Siatono on 2/12/14.
//  Copyright (c) 2014 Demo. All rights reserved.
//

import UIKit

let kNumberOfViews = 37
let kViewsPerRow = 5
let kViewMargin = 2.0
let kCellReuseIdentifier = "CellReuseIdentifier"

class RootViewController: UICollectionViewController {
    
    var coolSwich: UISwitch!
    var transitionDelegate: UIViewControllerTransitioningDelegate!
    var presentationShouldBeAwesome:Bool {
        get {
            return self.coolSwich.on
        }
    }

    // MARK: Init
    
    override init() {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
        
        self.configureTitleBar()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Controller Methods
    
    override func viewDidLoad() {
        // Register cell
        self.collectionView.registerClass(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: kCellReuseIdentifier)
        self.collectionView.backgroundColor = nil
        
        // Update layout margins
        let layout = self.collectionViewLayout as UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = CGFloat(kViewMargin)
        layout.minimumLineSpacing = CGFloat(kViewMargin)
        self.updateItemSizeInLayout(self.view.bounds.size)
    }
    
    override func supportedInterfaceOrientations() -> Int {
        
        // Return type Int is a bug, shoudl return UIInterfaceOrientationMask type
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        self.updateItemSizeInLayout(size)
    }
    
    func updateItemSizeInLayout(size: CGSize) {
        // Calculate item width
        var itemWidth = size.width / CGFloat(kViewsPerRow)
        itemWidth -= CGFloat(kViewMargin)
        
        // Update layout item size
        let layout = self.collectionViewLayout as UICollectionViewFlowLayout
        layout.itemSize = CGSizeMake(itemWidth, itemWidth)
        
        self.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: Helper Methods
    
    func configureTitleBar() {
        self.title = NSLocalizedString("LookInside Photos", comment: "App Title")
        self.edgesForExtendedLayout = UIRectEdge.Left | UIRectEdge.Right | UIRectEdge.Bottom
        
        // Init cool switch on the navigation bar
        self.coolSwich = UISwitch()
        self.coolSwich.onTintColor = UIColor.purpleColor()
        self.coolSwich.tintColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
        
        let barButton = UIBarButtonItem(customView: self.coolSwich)
        self.navigationItem.setLeftBarButtonItems([barButton], animated: false)
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let overlayViewController = OverlayViewController()
        
        // Set view controller transition delegate, note that you should not assign a local         
        // variable, doing so will cause dismissViewControllerAnimated() 
        // OverlayViewController to trigger EXC_BAD_ACCESS error
        if self.presentationShouldBeAwesome {
            self.transitionDelegate = CoolTransitioningDelegate()
        } else {
            self.transitionDelegate = OverlayTransitioningDelegate()
        }

        overlayViewController.transitioningDelegate = self.transitionDelegate
        
        
        
        // Pass selected cell to the view controller
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath)
        overlayViewController.photoViewCell = selectedCell as PhotoCollectionViewCell
        
        // Present view controller
        self.presentViewController(overlayViewController, animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kNumberOfViews
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellReuseIdentifier, forIndexPath: indexPath) as PhotoCollectionViewCell
        let image = UIImage(named: String(indexPath.item))
        
        cell.image = image
        
        return cell
    }
    
}
