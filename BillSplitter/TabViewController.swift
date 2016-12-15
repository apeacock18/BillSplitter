//
//  TabViewController.swift
//  BillSplitter
//
//  Created by gomeow on 4/25/16.
//  Copyright © 2016 Andrew Peacock. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let groupTable = GroupTableViewController()
        let nav = UINavigationController(rootViewController: groupTable)
        nav.title = "Groups"
        nav.tabBarItem.image = UIImage(named: "groups")

        let vc2 = MeViewController()
        vc2.title = "Me"
        vc2.tabBarItem.image = UIImage(named: "user")
        // let vc3 = SettingsViewController()
        // vc3.title = "Settings"
        // vc3.tabBarItem.image = UIImage(named: "settings")

        self.viewControllers = [nav, vc2]
        self.selectedIndex = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
