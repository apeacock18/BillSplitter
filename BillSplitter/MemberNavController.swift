//
//  MemberNavController.swift
//  BillSplitter
//
//  Created by gomeow on 5/4/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit
import Parse

class MemberNavController: UINavigationController {

    let memberController = MemberTableViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        memberController.title = "Members"
        memberController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Options", style: .Plain, target: self, action: #selector(MemberNavController.options))
        memberController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(MemberNavController.back))

        self.viewControllers = [memberController]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func back() {
        let vc = GroupNavViewController()
        vc.title = "Groups"
        (UIApplication.sharedApplication().delegate as! AppDelegate).tabViewController!.viewControllers![0] = vc
    }

    func options() {
        let vc = OptionsViewController()
        vc.users = memberController.members
        self.presentViewController(vc, animated: true, completion: nil)
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
                                let groupId = self.memberController.group!.getID()
                                NetworkManager.addUserToGroup(groupId, userId: userId) {
                                    (result: Int) in
                                    if result == 0 {
                                        VariableManager.addUserToGroup(userId, groupId: groupId)
                                        StorageManager.addUserToGroup(userId, groupId: groupId)
                                        self.memberController.group!.addMember(userId)
                                        self.memberController.members.append(userId)
                                        self.memberController.tableView.reloadData()
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
