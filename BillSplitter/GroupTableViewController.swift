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
            cell.membersLabel.text = String(group.count()) + " Members"

            return cell
        } else {
            return UITableViewCell() // TODO Create cell that says no groups
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = MemberNavController()
        vc.memberController.group = groups[indexPath.row]
        vc.memberController.members = groups[indexPath.row].getMembers()
        self.presentViewController(vc, animated: true, completion: nil)
        
        
    }
    
}
