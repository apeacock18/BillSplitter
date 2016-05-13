//
//  TransactionViewController.swift
//  BillSplitter
//
//  Created by gomeow on 5/12/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class TransactionViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var dateField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        dateField.delegate = self
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        dateField.text = formatter.stringFromDate(NSDate())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == dateField {
            dateField.resignFirstResponder()
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .NoStyle

            var initDate = formatter.dateFromString(dateField.text!)
            if initDate == nil {
                initDate = NSDate()
            }

            let dateController = DatePickerViewController()
            //dateController.datePicker.date = initDate!

            dateController.modalPresentationStyle = .Popover
            dateController.preferredContentSize = CGSizeMake(self.view.frame.width, 254.0)

            let popOverController = dateController.popoverPresentationController
            popOverController?.permittedArrowDirections = .Up
            popOverController?.delegate = self
            popOverController?.sourceView = dateField
            popOverController?.sourceRect = dateField.bounds

            self.presentViewController(dateController, animated: true, completion: nil)

            return false
        } else {
            return true
        }
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

}
