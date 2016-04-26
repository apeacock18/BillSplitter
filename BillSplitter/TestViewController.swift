//
//  TestViewController.swift
//  BillSplitter
//
//  Created by gomeow on 4/25/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func readData() -> String {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let data = defaults.objectForKey("selfData") as? NSData {
            
            let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [String:String]
            return dict["fName"]!+" "+dict["lName"]!+" "+dict["username"]!+" "+dict["email"]!
        } else {
            return "nil"
        }
    }

    @IBAction func doIt(sender: UIButton) {
        label.text = readData()
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
