//
//  TransactionViewController.swift
//  BillSplitter
//
//  Created by gomeow on 5/12/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class TransactionViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, DatePickerVCDelegate, DropDownDelegate {

    @IBOutlet weak var desc: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var shareWith: UITextField!

    var selectedUsers: [String] = []

    var group: Group?

    override func viewDidLoad() {
        super.viewDidLoad()
        dateField.delegate = self
        shareWith.delegate = self
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        dateField.text = formatter.stringFromDate(NSDate())
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == dateField {
            resignAllResponders()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"

            let initDate = formatter.dateFromString(dateField.text!)
            print(initDate)

            let dateController = DatePickerViewController()
            dateController.delegate = self
            dateController.initDate = initDate

            dateController.modalPresentationStyle = .Popover
            dateController.preferredContentSize = CGSizeMake(self.view.frame.width, 254.0)

            let popOverController = dateController.popoverPresentationController
            popOverController?.permittedArrowDirections = .Up
            popOverController?.delegate = self
            popOverController?.sourceView = dateField
            popOverController?.sourceRect = dateField.bounds

            self.presentViewController(dateController, animated: true, completion: nil)

            return false
        } else if textField == shareWith {
            resignAllResponders()
            let dropDownTable = DropDownTable()
            dropDownTable.delegate = self
            dropDownTable.members = group!.getMembers()
            dropDownTable.selectedMembers = selectedUsers

            dropDownTable.modalPresentationStyle = .Popover

            var height: Int = 220

            if group!.count() <= 5 {
                height = (group!.getMembers().count * 44) - 1
            }
            dropDownTable.preferredContentSize = CGSizeMake(self.view.frame.width, CGFloat(height))

            let popOverController = dropDownTable.popoverPresentationController
            popOverController?.permittedArrowDirections = .Up
            popOverController?.delegate = self
            popOverController?.sourceView = shareWith
            popOverController?.sourceRect = shareWith.bounds

            self.presentViewController(dropDownTable, animated: true, completion: nil)

            return false
        } else {
            return true
        }
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    func datePicked(sender: DatePickerViewController, date: NSDate) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        
        dateField.text = formatter.stringFromDate(date)
    }

    func usersPicked(sender: DropDownTable, users: [String]) {
        if users.count == 0 {
            shareWith.text = ""
        } else if users.count == 1 {
            shareWith.text = String(users.count) + " member"
        } else {
            shareWith.text = String(users.count) + " members"
        }
        selectedUsers = users
    }

    func resignAllResponders() {
        desc.resignFirstResponder()
        shareWith.resignFirstResponder()
        dateField.resignFirstResponder()
        amount.resignFirstResponder()
    }

}
