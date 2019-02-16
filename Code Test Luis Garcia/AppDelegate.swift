//
//  AppDelegate.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/19/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CoreDataManager.shared.setup {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let navViewController = UINavigationController(rootViewController: ContactsViewController())
            self.window?.rootViewController = navViewController
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }
}

