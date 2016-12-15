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

    let currencyFormatter = NumberFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80.0
        self.title = group!.getName()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(MemberTableViewController.options))
        NetworkManager.memberDelegate = self
        self.currencyFormatter.numberStyle = .currency
        self.currencyFormatter.locale = Locale.current

        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(MemberTableViewController.refresh), for: .valueChanged)
        tableView.addSubview(refreshControl!)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NetworkManager.memberDelegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cellIdentifier = "CreateCell"
            tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CreateCell
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        } else {
            let cellIdentifier = "MemberCell"
            tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MemberCell
            let id = members[indexPath.row - 1]
            let user = VariableManager.getUserById(id: id)
            cell.name.text = user?.name
            cell.name.adjustsFontSizeToFitWidth = true
            cell.avatar.image = user?.getAvatar()
            cell.amount.adjustsFontSizeToFitWidth = true
            let status = group!.getStatusById(userId: VariableManager.getID())
            let amount: Double = status!.getAmountByRecipient(userId: id) ?? 0.0
            if amount <= 0.0 {
                cell.whoOwes.text = "They Owe"
                cell.amount.textColor = UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1) // #27ae60
                if amount == 0 {
                    cell.amount.text = String(NSString(format: "$%.2f", amount))
                } else {
                    cell.amount.text = String(NSString(format: "$%.2f", -amount))
                }
            } else {
                cell.whoOwes.text = "You Owe"
                cell.amount.textColor = UIColor.red
                cell.amount.text = String(NSString(format: "$%.2f", amount))
            }
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row != 0) {
            let member = members[indexPath.row - 1]
            let payBack = UIAlertController(title: "Pay Back", message: "", preferredStyle: .alert)
            payBack.addTextField(configurationHandler: {
                (textField: UITextField!) in
                textField.text = "\(self.currencyFormatter.currencySymbol!)0.00"
                textField.keyboardType = .numberPad
                textField.addTarget(self, action: #selector(MemberTableViewController.textFieldDidChange(textField:)), for: .editingChanged)
            })
            let okButton = UIAlertAction(title: "OK", style: .default) {
                (paramAction: UIAlertAction) in
                if let textFields = payBack.textFields {
                    let fields = textFields as [UITextField]
                    let text = fields[0].text
                    if text != nil && text != "" {
                        NetworkManager.payBack(groupId: self.group!.getID(), payFrom: member, payTo: VariableManager.getID(), amount: Double(self.currencyFormatter.number(from: text!)!)) {
                            (result: Bool) in
                            if result {
                                NetworkManager.refreshStatus(groupId: self.group!.getID()) {
                                    OperationQueue.main.addOperation {
                                        self.tableView.reloadData()
                                    }
                                }
                            } else {
                                let message = UIAlertController(title: "Error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                                message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(message, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }

            payBack.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            payBack.addAction(okButton)
            self.present(payBack, animated: true, completion: nil)
        }
    }

    func options() {
        let vc = OptionsViewController()
        vc.users = members
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func add() {
        let addUser = UIAlertController(title: "Enter a username", message: nil, preferredStyle: .alert)
        addUser.addTextField(configurationHandler: {
            (textField: UITextField!) in
            textField.placeholder = "Username"

        })
        let add = UIAlertAction(title: "Add", style: .default) {
            (paramAction: UIAlertAction) in
            if let textFields = addUser.textFields {
                let fields = textFields as [UITextField]
                let text = fields[0].text
                if text != nil && text != "" {
                    NetworkManager.userExists(username: text!) {
                        (result: String?) in
                        if result == nil {
                            let message = UIAlertController(title: "Invalid username", message: "That username does not exist.", preferredStyle: UIAlertControllerStyle.alert)
                            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(message, animated: true, completion: nil)
                        } else {
                            let userId: String = result!
                            if userId != VariableManager.getID() {
                                let groupId = self.group!.getID()
                                NetworkManager.addUserToGroup(groupId: groupId, userId: userId) {
                                    (result: Int) in
                                    if result == 0 {
                                        NetworkManager.refreshStatus(groupId: groupId) {
                                            if !VariableManager.containsUser(userId: userId) {
                                                NetworkManager.getUser(userId: userId) {
                                                    (result: User?) in
                                                    if result != nil {
                                                        VariableManager.addUser(user: result!)
                                                        VariableManager.addUserToGroup(userId: userId, groupId: groupId)
                                                        OperationQueue.main.addOperation {
                                                            self.members.append(userId)
                                                            self.tableView.reloadData()
                                                            let index = self.tableView.numberOfRows(inSection: 0) - 1
                                                            let indexPath = IndexPath(row: index, section: 0)
                                                            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                                                        }
                                                        NetworkManager.getAvatarFromServer(userId: result!.id) {
                                                            (image) -> Void in
                                                            if image != nil {
                                                                VariableManager.addAvatarToUser(userId: result!.id, avatar: image!)
                                                                OperationQueue.main.addOperation {
                                                                    self.tableView.reloadData()
                                                                    let index = self.tableView.numberOfRows(inSection: 0) - 1
                                                                    let indexPath = IndexPath(row: index, section: 0)
                                                                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            } else {
                                                OperationQueue.main.addOperation {
                                                    VariableManager.addUserToGroup(userId: userId, groupId: groupId)
                                                    self.members.append(userId)
                                                    self.tableView.reloadData()
                                                }
                                            }
                                        }
                                    } else if result == 6 {
                                        let message = UIAlertController(title: "Invalid username", message: "That username does not exist.", preferredStyle: UIAlertControllerStyle.alert)
                                        message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(message, animated: true, completion: nil)
                                    } else if result == 7 {
                                        let message = UIAlertController(title: "Error", message: "That user is already in this group.", preferredStyle: UIAlertControllerStyle.alert)
                                        message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(message, animated: true, completion: nil)
                                    } else {
                                        let message = UIAlertController(title: "Error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                                        message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(message, animated: true, completion: nil)
                                    }
                                }
                            } else {
                                let message = UIAlertController(title: "Invalid username", message: "You cannot add yourself to a group.", preferredStyle: UIAlertControllerStyle.alert)
                                message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(message, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        addUser.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        addUser.addAction(add)
        self.present(addUser, animated: true, completion: nil)
    }

    func refresh() {
        VariableManager.reloadGroups() {
            (result) -> Void in
            if result {
                OperationQueue.main.addOperation {
                    self.refreshControl?.endRefreshing()
                    self.dataReloadNeeded()
                    let index = self.tableView.numberOfRows(inSection: 0) - 1
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            } else {
                self.refreshControl?.endRefreshing()
                let message = UIAlertController(title: "Error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(message, animated: true, completion: nil)
            }
        }
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
            self.present(vc, animated: true, completion: nil)
        } else {
            let vc = HistoryTableViewController()
            vc.group = group
            vc.transactions = group!.getTransactions()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func textFieldDidChange(textField: UITextField) {

        let text = textField.text!.replacingOccurrences(of: currencyFormatter.currencySymbol, with: "").replacingOccurrences(of: currencyFormatter.groupingSeparator, with: "").replacingOccurrences(of: currencyFormatter.decimalSeparator, with: "")

        let newText = currencyFormatter.string(from: NSNumber(value: (text as NSString).doubleValue / 100.0))
        
        textField.text = newText
        print(newText)
    }
    
}
