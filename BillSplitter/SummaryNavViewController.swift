//
//  SummaryNavViewController.swift
//  BillSplitter
//
//  Created by gomeow on 4/26/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class SummaryNavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers = [SummaryTableViewController()]
        
        let button = UIButton(type: .Custom)
        button.setTitle("+", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(20.0)
        button.frame = CGRectMake(0, 0, 100, 40)
        self.navigationBar.topItem?.title = "Groups"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .Plain, target: self, action: #selector(SummaryNavViewController.onCreate))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.systemFontOfSize(40)], forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onCreate() {
        
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
