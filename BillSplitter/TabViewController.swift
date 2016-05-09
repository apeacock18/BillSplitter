//
//  TabViewController.swift
//  BillSplitter
//
//  Created by gomeow on 4/25/16.
//  Copyright © 2016 Andrew Peacock. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let groupTable = GroupTableViewController()
        let nav = UINavigationController(rootViewController: groupTable)
        nav.title = "Groups"
        nav.tabBarItem.image = UIImage(named: "groups")

        let vc2 = MeViewController()
        vc2.title = "Me"
        vc2.tabBarItem.image = UIImage(named: "user")
        // let vc3 = SettingsViewController
        // vc3.title = "Settings"
        // vc3.tabBarItem.image = UIImage(named: "settings")

        self.viewControllers = [nav, vc2]
        self.selectedIndex = 0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
