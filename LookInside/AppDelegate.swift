//
//  AppDelegate.swift
//  LookInside
//
//  Created by Herryanto Siatono on 2/12/14.
//  Copyright (c) 2014 Demo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Init window
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.makeKeyAndVisible()
        
        // Init root view controller
        let rootViewController = RootViewController()
        let navController = UINavigationController(rootViewController: rootViewController)
        
        self.window?.rootViewController = navController
        
        return true
    }
}
