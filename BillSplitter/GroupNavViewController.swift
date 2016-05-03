//
//  SummaryNavViewController.swift
//  BillSplitter
//
//  Created by gomeow on 4/26/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class GroupNavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers = [GroupTableViewController()]

        self.navigationBar.topItem?.title = "Groups"

        let button = UIButton(type: .Custom)
        button.setTitle("+", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(20.0)
        button.frame = CGRectMake(0, 0, 100, 40)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .Plain, target: self, action: #selector(GroupNavViewController.onCreate))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.systemFontOfSize(40)], forState: .Normal)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(GroupNavViewController.onCreate))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onCreate() {
        let createGroup = UIAlertController(title: "Enter a group name", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        createGroup.addTextFieldWithConfigurationHandler({
            (textField: UITextField!) in
            textField.placeholder = "Group Name"
        })

        let create = UIAlertAction(title: "Create", style: .Default) {
            (paramAction: UIAlertAction) in
            if let textFields = createGroup.textFields {
                let fields = textFields as [UITextField]
                let text = fields[0].text
                if text == nil || text == "" {

                } else {
                    NetworkManager.createGroup(text!) {
                        (result: String?) in
                        if result != nil {
                            let groupId: String = result!
                            NetworkManager.addUserToGroup(groupId, userId: VariableManager.getID()) {
                                (result: Bool) in
                                if result {
                                    StorageManager.addUserToGroup(VariableManager.getID(), groupId: groupId)
                                    VariableManager.addGroup(Group(id: groupId, name: text!, members: [VariableManager.getID()]))
                                } else {
                                    self.handleError()
                                }
                            }
                        } else {
                            self.handleError()
                        }
                    }
                }
            }
        }
        createGroup.addAction(create)

    }

    func handleError() {
        let message = UIAlertController(title: "Error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
        message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(message, animated: true, completion: nil)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
