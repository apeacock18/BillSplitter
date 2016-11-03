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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.usersPicked(sender: self, users: selectedMembers)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let member = members[indexPath.row]
        let cellIdentifier = "DropDownCell"
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DropDownCell
        cell.nameField.text = VariableManager.getUserById(id: member)!.name
        cell.id = member
        cell.selectionStyle = .none
        if selectedMembers.contains(member) {
            cell.accessoryType = .checkmark
        }


        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DropDownCell

        if cell.isSelected {
            cell.isSelected = false
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
                selectedMembers.append(cell.id)
            } else {
                cell.accessoryType = .none
                selectedMembers = selectedMembers.filter { $0 != cell.id}
            }
        }
    }

}
