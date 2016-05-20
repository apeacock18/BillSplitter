//
//  MemberTableViewController.swift
//  BillSplitter
//
//  Created by gomeow on 5/4/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit
import Parse

class MemberTableViewController: UITableViewController, ReloadDelegate, GroupButtonBarDelegate {

    var group: Group?
    var members: Array<String> = []

    let currencyFormatter = NSNumberFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80.0
        self.title = group!.getName()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Options", style: .Plain, target: self, action: #selector(MemberTableViewController.options))
        NetworkManager.delegate = self
        self.currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        self.currencyFormatter.currencyCode = NSLocale.currentLocale().displayNameForKey(NSLocaleCurrencySymbol, value: NSLocaleCurrencyCode)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NetworkManager.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cellIdentifier = "CreateCell"
            tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CreateCell
            cell.delegate = self
            cell.selectionStyle = .None
            return cell
        } else {
            let cellIdentifier = "MemberCell"
            tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MemberCell
            let id = members[indexPath.row - 1]
            let user = VariableManager.getUserById(id)
            cell.name.text = user?.name
            cell.name.adjustsFontSizeToFitWidth = true
            cell.avatar.image = user?.getAvatar()
            cell.amount.adjustsFontSizeToFitWidth = true
            let status = group!.getStatusById(VariableManager.getID())
            let amount: Double = status!.getAmountByRecipient(id)!
            if amount <= 0 {
                cell.whoOwes.text = "They Owe:"
                cell.amount.textColor = UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1) // #27ae60
                if amount == 0 {
                    cell.amount.text = String(NSString(format: "$%.2f", amount))
                } else {
                    cell.amount.text = String(NSString(format: "$%.2f", -amount))
                }
            } else {
                cell.whoOwes.text = "You Owe:"
                cell.amount.textColor = UIColor.redColor()
                cell.amount.text = String(NSString(format: "$%.2f", amount))
            }
            return cell
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let member = members[indexPath.row - 1]
        let payBack = UIAlertController(title: "Pay Back", message: "", preferredStyle: .Alert)
        payBack.addTextFieldWithConfigurationHandler({
            (textField: UITextField!) in
            textField.text = "\(self.currencyFormatter.currencySymbol)0.00"
            textField.keyboardType = .NumberPad
            textField.addTarget(self, action: #selector(MemberTableViewController.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        })
        let okButton = UIAlertAction(title: "OK", style: .Default) {
            (paramAction: UIAlertAction) in
            if let textFields = payBack.textFields {
                let fields = textFields as [UITextField]
                let text = fields[0].text
                if text != nil && text != "" {
                    NetworkManager.payBack(self.group!.getID(), payFrom: member, payTo: VariableManager.getID(), amount: Double(self.currencyFormatter.numberFromString(text!)!)) {
                        (result: Bool) in
                        if result {
                            NetworkManager.refreshStatus(self.group!.getID()) {
                                self.tableView.reloadData()
                            }
                        } else {
                            let message = UIAlertController(title: "Error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(message, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        payBack.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        payBack.addAction(okButton)
        self.presentViewController(payBack, animated: true, completion: nil)
    }

    func options() {
        let vc = OptionsViewController()
        vc.users = members
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func add() {
        let addUser = UIAlertController(title: "Enter a username", message: nil, preferredStyle: .Alert)
        addUser.addTextFieldWithConfigurationHandler({
            (textField: UITextField!) in
            textField.placeholder = "Username"

        })
        let add = UIAlertAction(title: "Add", style: .Default) {
            (paramAction: UIAlertAction) in
            if let textFields = addUser.textFields {
                let fields = textFields as [UITextField]
                let text = fields[0].text
                if text != nil && text != "" {
                    NetworkManager.userExists(text!) {
                        (result: String?) in
                        if result == nil {
                            let message = UIAlertController(title: "Invalid username", message: "That username does not exist.", preferredStyle: UIAlertControllerStyle.Alert)
                            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(message, animated: true, completion: nil)
                        } else {
                            let userId: String = result!
                            if userId != VariableManager.getID() {
                                let groupId = self.group!.getID()
                                NetworkManager.addUserToGroup(groupId, userId: userId) {
                                    (result: Int) in
                                    if result == 0 {
                                        NetworkManager.refreshStatus(groupId) {
                                            if !VariableManager.containsUser(userId) {
                                                NetworkManager.getUser(userId) {
                                                    (result: User?) in
                                                    if result != nil {
                                                        VariableManager.addUser(result!)
                                                        VariableManager.addUserToGroup(userId, groupId: groupId)
                                                        StorageManager.addUserToGroup(userId, groupId: groupId)
                                                        self.members.append(userId)
                                                        self.tableView.reloadData()
                                                        let index = self.tableView.numberOfRowsInSection(0) - 1
                                                        let indexPath = NSIndexPath(forRow: index, inSection: 0)
                                                        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
                                                    }
                                                }
                                            } else {
                                                VariableManager.addUserToGroup(userId, groupId: groupId)
                                                StorageManager.addUserToGroup(userId, groupId: groupId)
                                                self.members.append(userId)
                                                self.tableView.reloadData()
                                            }
                                        }
                                    } else if result == 1 {
                                        let message = UIAlertController(title: "Error", message: "That user is already in this group.", preferredStyle: UIAlertControllerStyle.Alert)
                                        message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                        self.presentViewController(message, animated: true, completion: nil)
                                    } else {
                                        // TODO Error
                                    }
                                }
                            } else {
                                let message = UIAlertController(title: "Invalid username", message: "You cannot add yourself to a group.", preferredStyle: UIAlertControllerStyle.Alert)
                                message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(message, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        addUser.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        addUser.addAction(add)
        self.presentViewController(addUser, animated: true, completion: nil)
    }

    func dataReloadNeeded() {
        tableView.reloadData()
    }

    func buttonPressed(index: Int) {
        if index == 0 {
            add()
        } else  if index == 1 { // Add Transaction
            let vc = TransactionViewController()
            vc.delegate = self
            vc.group = group
            self.presentViewController(vc, animated: true, completion: nil)
        } else {
            let vc = HistoryTableViewController()
            vc.group = group
            vc.transactions = group!.getTransactions()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func textFieldDidChange(textField: UITextField) {
        let text = textField.text!.stringByReplacingOccurrencesOfString(currencyFormatter.currencySymbol, withString: "").stringByReplacingOccurrencesOfString(currencyFormatter.groupingSeparator, withString: "").stringByReplacingOccurrencesOfString(currencyFormatter.decimalSeparator, withString: "")
        textField.text = currencyFormatter.stringFromNumber((text as NSString).doubleValue / 100.0)
    }

}
