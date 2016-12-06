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

    var delegate: ReloadDelegate?

    let currencyFormatter = NumberFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        dateField.delegate = self
        shareWith.delegate = self
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        dateField.text = formatter.string(from: Date())
        self.hideKeyboardWhenTappedAround()

        amount.keyboardType = .numberPad
        amount.addTarget(self, action: #selector(TransactionViewController.textField(_:shouldChangeCharactersIn:replacementString:)), for: UIControlEvents.editingChanged)
        amount.text = "\(currencyFormatter.currencySymbol!)0.00"

        currencyFormatter.numberStyle = NumberFormatter.Style.currency

        currencyFormatter.currencyCode = Locale.current.currencyCode
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == dateField {
            resignAllResponders()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"

            let initDate = formatter.date(from: dateField.text!)

            let dateController = DatePickerViewController()
            dateController.delegate = self
            dateController.initDate = initDate

            dateController.modalPresentationStyle = .popover
            dateController.preferredContentSize = CGSize(width: self.view.frame.width, height: 254.0)

            let popOverController = dateController.popoverPresentationController
            popOverController?.permittedArrowDirections = .up
            popOverController?.delegate = self
            popOverController?.sourceView = dateField
            popOverController?.sourceRect = dateField.bounds

            self.present(dateController, animated: true, completion: nil)

            return false
        } else if textField == shareWith {
            resignAllResponders()
            let dropDownTable = DropDownTable()
            dropDownTable.delegate = self
            dropDownTable.members = group!.getMembers().filter {$0 != VariableManager.getID()}
            dropDownTable.selectedMembers = selectedUsers

            dropDownTable.modalPresentationStyle = .popover

            var height: Int = 220

            if group!.count() <= 5 {
                height = ((group!.getMembers().count - 1) * 44) - 1
            }
            dropDownTable.preferredContentSize = CGSize(width: self.view.frame.width, height: CGFloat(height))

            let popOverController = dropDownTable.popoverPresentationController
            popOverController?.permittedArrowDirections = .up
            popOverController?.delegate = self
            popOverController?.sourceView = shareWith
            popOverController?.sourceRect = shareWith.bounds

            self.present(dropDownTable, animated: true, completion: nil)

            return false
        } else {
            return true
        }
    }

    @IBAction func newTransaction(_ sender: UIButton) {
        if desc.text!.characters.count == 0 {
            let message = UIAlertController(title: "No description", message: "Please enter a description.", preferredStyle: UIAlertControllerStyle.alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(message, animated: true, completion: nil)
            return
        }
        if amount.text!.characters.count == 0 {
            let message = UIAlertController(title: "No amount entered", message: "Please enter a bill amount.", preferredStyle: UIAlertControllerStyle.alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(message, animated: true, completion: nil)
            return
        }
        if selectedUsers.count == 0 {
            let message = UIAlertController(title: "No users selected", message: "Please select at least one user to shhare the bill with.", preferredStyle: UIAlertControllerStyle.alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(message, animated: true, completion: nil)
            return
        }

        self.dismiss(animated: true, completion: nil)

        NetworkManager.newTransaction(groupId: group!.getID(), payee: VariableManager.getID(), amount: Double(currencyFormatter.number(from: amount.text!)!), description: desc.text!, date: dateField.text!, users: selectedUsers) {
            (result: Bool) in
            NetworkManager.refreshStatus(groupId: self.group!.getID()) {
                self.delegate?.dataReloadNeeded()
            }
        }
    }

    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func datePicked(sender: DatePickerViewController, date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        
        dateField.text = formatter.string(from: date)
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text!.replacingOccurrences(of: currencyFormatter.currencySymbol, with: "").replacingOccurrences(of: currencyFormatter.groupingSeparator, with: "").replacingOccurrences(of: currencyFormatter.decimalSeparator, with: "")
        textField.text = currencyFormatter.string(from: NSNumber(value: (text as NSString).doubleValue / 100.0))
        return true
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

}
