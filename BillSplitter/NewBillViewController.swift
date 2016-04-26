//
//  NewBillViewController.swift
//  BillSplitter
//
//  Created by gomeow on 4/25/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class NewBillViewController: UIViewController {

    @IBOutlet weak var paid: UITextField!
    @IBOutlet weak var sharing: UITextField!
    @IBOutlet weak var billDescription: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.navigationController?.popToViewController(LoginViewController(), animated: true)
    }

    @IBAction func add(sender: UIButton) {
    }
    
    @IBAction func datepicked(sender: UIDatePicker) {
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
