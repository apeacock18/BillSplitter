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
        return members.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "MemberCell"
        tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MemberCell
        cell.name.text = members[indexPath.row]

        cell.avatar.image = UIImage(named: "default")
        cell.amount.text = "$0.00"
        return cell
    }


}
