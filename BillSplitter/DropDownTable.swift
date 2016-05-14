//
//  DropDownTable.swift
//  BillSplitter
//
//  Created by gomeow on 5/13/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class DropDownTable: UITableViewController {

    var members: [String] = []

    var selectedMembers: [String] = []

    var delegate: DropDownDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.usersPicked(self, users: selectedMembers)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let member = members[indexPath.row]
        let cellIdentifier = "DropDownCell"
        tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DropDownCell
        cell.nameField.text = VariableManager.getUserById(member)!.name
        cell.id = member
        cell.selectionStyle = .None
        if selectedMembers.contains(member) {
            cell.accessoryType = .Checkmark
        }


        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! DropDownCell

        if cell.selected {
            cell.selected = false
            if cell.accessoryType == .None {
                cell.accessoryType = .Checkmark
                selectedMembers.append(cell.id)
            } else {
                cell.accessoryType = .None
                selectedMembers = selectedMembers.filter { $0 != cell.id}
            }
        }
    }

}
