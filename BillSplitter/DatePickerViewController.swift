//
//  DatePickerViewController.swift
//  BillSplitter
//
//  Created by gomeow on 5/12/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!

    weak var delegate: DatePickerVCDelegate?

    var initDate: NSDate?

    override func viewDidLoad() {
        super.viewDidLoad()
        if initDate != nil {
            datePicker.date = initDate!
        }
        datePicker.maximumDate = NSDate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func ok(sender: UIButton) {
        delegate?.datePicked(self, date: datePicker.date)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
