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
        
        let vc1 = TestViewController()
        vc1.title = "Test"
        let vc2 = NewBillViewController()
        vc2.title = "Bill"
        
        self.viewControllers = [vc1, vc2]
        self.selectedIndex = 1
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
