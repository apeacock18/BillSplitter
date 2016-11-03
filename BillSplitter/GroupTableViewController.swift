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

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(GroupTableViewController.logout))
        self.title = "Groups"
        let button = UIButton(type: .custom)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(GroupTableViewController.onCreate))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 40)], for: .normal)


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


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if groups.count != 0 {
            let cellIdentifier = "GroupCell"
            tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GroupCell
            cell.selectionStyle = .none
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        self.present(LoginViewController(), animated: true, completion: nil)
        VariableManager.erase()
    }

    func onCreate() {
        let createGroup = UIAlertController(title: "Enter a group name", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        createGroup.addTextField(configurationHandler: {
            (textField: UITextField!) in
            textField.placeholder = "Group Name"
        })

        let create = UIAlertAction(title: "Create", style: .default) {
            (paramAction: UIAlertAction) in
            if let textFields = createGroup.textFields {
                let fields = textFields as [UITextField]
                let text = fields[0].text
                if text == nil || text == "" {

                } else {
                    NetworkManager.createGroup(name: text!) {
                        (result: String?) in
                        if result != nil {
                            let groupId: String = result!
                            NetworkManager.addUserToGroup(groupId: groupId, userId: VariableManager.getID()) {
                                (result: Int) in
                                if result == 0 {
                                    VariableManager.addGroup(group: Group(id: groupId, name: text!, members: [VariableManager.getID()]))
                                    NetworkManager.refreshStatus(groupId: groupId) {
                                        () in
                                        StorageManager.createGroup(id: groupId, name: text!)
                                        StorageManager.addUserToGroup(id: VariableManager.getID(), groupId: groupId)
                                        self.reload()
                                        let index = self.tableView.numberOfRows(inSection: 0) - 1
                                        let indexPath = IndexPath(row: index, section: 0)
                                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                                    }
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
        createGroup.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        createGroup.addAction(create)
        self.present(createGroup, animated: true, completion: nil)
        
    }

    func handleError() {
        let message = UIAlertController(title: "Error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
        message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(message, animated: true, completion: nil)
    }


}
