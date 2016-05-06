//
//  AppDelegate.swift
//  p2
//
//  Created by Andrew Peacock on 3/10/16.
//  Copyright © 2016 Andrew Peacock. All rights reserved.
//

import Parse
import Bolts
import UIKit
import CryptoSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var loginViewController: LoginViewController?
    var tabViewController: TabViewController?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let configuration = ParseClientConfiguration {
            $0.applicationId = "SmKujk7VXA7gQcUNz6hHjbPWpk1jF0Wtp1RPZ71Z"
            $0.server = "https://parseapi.back4app.com/"
            $0.clientKey = "g1gsXIi0t2Hk1maTsl5lXGbEaqLMlIQE8MludaDW"
        }
        Parse.initializeWithConfiguration(configuration)

        loginViewController = LoginViewController()
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.rootViewController = loginViewController
        self.window!.makeKeyAndVisible()

        /* TODO: These should be used when local storage is used instead of getting all information from the server.
        StorageManager.recallSelfData()
        StorageManager.recallGroupData()
        */

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        NSUserDefaults.standardUserDefaults().synchronize()
    }


    struct Variables {
        // Store main variables here?
    }


}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }

    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return (navigation.visibleViewController?.topMostViewController())!
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}

extension String {
    func hashWithSalt(salt: String) -> String {
        var password: String = self
        password += salt
        return password.sha512()
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}

