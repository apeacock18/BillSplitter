//
//  SpinnerView.swift
//  BillSplitter
//
//  Created by gomeow on 5/3/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class SpinnerView: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor.blackColor()
        let spinner = Spinner(text: "Logging in")
        //self.view.tintColor = UIColor.grayColor()
        self.view.addSubview(spinner)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
