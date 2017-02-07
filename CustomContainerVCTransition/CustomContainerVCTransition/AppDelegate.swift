//
//  AppDelegate.swift
//  CustomContainerVCTransition
//
//  Created by seedante on 15/12/24.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var containerVCDelegate: SDEContainerViewControllerDelegate?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = configureRootViewController()
        window?.makeKeyAndVisible()
        return true
    }

    func configureRootViewController() -> UIViewController{
        
        let subVC0 = ViewController()
        subVC0.view.backgroundColor = UIColor(red: 0.4, green: 0.8, blue: 1, alpha: 1)
        subVC0.title = "DC"
        let subVC1 = ViewController()
        subVC1.view.backgroundColor = UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 1)
        subVC1.title = "Marvel"
        let subVC2 = ViewController()
        subVC2.view.backgroundColor = UIColor(red: 0.3, green: 0.8, blue: 0.4, alpha: 1)
        subVC2.title = "DHC"
        let subVC3 = ViewController()
        subVC3.view.backgroundColor = UIColor(red: 0.5, green: 0.4, blue: 0.5, alpha: 1)
        subVC3.title = "Image"
        
        let containerController = SDETabBarViewController(viewControllers: [subVC0 ,subVC1, subVC2, subVC3])
        containerVCDelegate = SDEContainerViewControllerDelegate()
        containerController.containerTransitionDelegate = containerVCDelegate
        
        return containerController
    }
}

