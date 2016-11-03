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

    var initDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        if initDate != nil {
            datePicker.date = initDate!
        }
        datePicker.maximumDate = Date()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func ok(_ sender: UIButton) {
        delegate?.datePicked(sender: self, date: datePicker.date)
        self.dismiss(animated: true, completion: nil)
    }
}
