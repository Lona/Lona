//
//  AppDelegate.swift
//  LonaViewer
//
//  Created by Jason Zurita on 3/2/18.
//  Copyright © 2018 Lona. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let vc = ViewSelectionVC()
        let navVC = UINavigationController()
        navVC.viewControllers = [vc]
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
        return true
    }
}

