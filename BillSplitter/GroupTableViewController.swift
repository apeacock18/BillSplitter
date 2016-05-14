//
//  SummaryTableViewController.swift
//  BillSplitter
//
//  Created by gomeow on 4/26/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class GroupTableViewController: UITableViewController {

    var groups: Array<Group> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGroups()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80.0

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(GroupTableViewController.logout))
        self.title = "Groups"
        let button = UIButton(type: .Custom)
        button.setTitle("+", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(20.0)
        button.frame = CGRectMake(0, 0, 100, 40)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .Plain, target: self, action: #selector(GroupTableViewController.onCreate))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.systemFontOfSize(40)], forState: .Normal)


    }

    func loadGroups() {
        groups = VariableManager.getGroups()
    }

    func reload() {
        loadGroups()
        tableView.reloadData()
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
        return groups.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if groups.count != 0 {
            let cellIdentifier = "GroupCell"
            tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GroupCell

            let group = groups[indexPath.row]
            cell.groupNameLabel.text = group.getName()

            if group.count() == 0 {
                cell.membersLabel.text = ""
            } else if group.count() == 1 {
                cell.membersLabel.text = String(group.count()) + " member"
            } else {
                cell.membersLabel.text = String(group.count()) + " members"
            }

            return cell
        } else {
            return UITableViewCell() // TODO Create cell that says no groups
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = MemberTableViewController()
        vc.group = groups[indexPath.row]
        vc.members = groups[indexPath.row].getMembers().filter { $0 != VariableManager.getID() }
        vc.title = "Groups"
        //let nav = UINavigationController(rootViewController: vc)
        self.navigationController?.pushViewController(vc, animated: true)


        /*let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.tabViewController?.viewControllers![0] = vc*/
    }

    func logout() {
        let appDomain = NSBundle.mainBundle().bundleIdentifier!
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
        self.presentViewController(LoginViewController(), animated: true, completion: nil)
        VariableManager.erase()
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
                                (result: Int) in
                                if result == 0 {
                                    VariableManager.addGroup(Group(id: groupId, name: text!, members: [VariableManager.getID()]))
                                    NetworkManager.refreshStatus(groupId) {
                                        () in
                                        StorageManager.createGroup(groupId, name: text!)
                                        StorageManager.addUserToGroup(VariableManager.getID(), groupId: groupId)
                                        self.reload()                                    }
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
        createGroup.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        createGroup.addAction(create)
        self.presentViewController(createGroup, animated: true, completion: nil)
        
    }

    func handleError() {
        let message = UIAlertController(title: "Error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
        message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(message, animated: true, completion: nil)
    }


}
