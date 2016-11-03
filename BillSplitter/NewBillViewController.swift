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

    @IBAction func cancel(_ sender: UIButton) {
        _ = self.navigationController?.popToViewController(LoginViewController(), animated: true)
    }

    @IBAction func add(_ sender: UIButton) {
    }

    @IBAction func datepicked(_ sender: UIDatePicker) {
    }
    
}
