//
//  MemberTableViewController.swift
//  BillSplitter
//
//  Created by gomeow on 5/4/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class MemberTableViewController: UITableViewController {

    var group: Group? = nil
    var members: Array<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80.0

        self.title = "Members"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Options", style: .Plain, target: self, action: #selector(MemberTableViewController.options))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

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
            return cell
        } else {
            let cellIdentifier = "MemberCell"
            tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MemberCell

            let id = members[indexPath.row - 1]
            if id == VariableManager.getID() {
                cell.name.text = VariableManager.getName()
                cell.avatar.image = VariableManager.getAvatar()
            } else {
                let user = VariableManager.getUserById(id)
                cell.name.text = user?.username
                cell.avatar.image = user?.getAvatar()
            }
            cell.amount.text = "$0.00"
            return cell
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 { // Add Transaction
            add()
        }

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
                                        VariableManager.addUserToGroup(userId, groupId: groupId)
                                        StorageManager.addUserToGroup(userId, groupId: groupId)
                                        self.group!.addMember(userId)
                                        self.members.append(userId)
                                        self.tableView.reloadData()
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

}
