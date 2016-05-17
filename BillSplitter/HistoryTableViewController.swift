//
//  HistoryTableViewController.swift
//  BillSplitter
//
//  Created by gomeow on 5/16/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {

    var group: Group?
    var transactions: [Transaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "History"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "HistoryCell"
        tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! HistoryCell
        let transaction = transactions[indexPath.row]
        cell.payee.text = VariableManager.getUserById(transaction.payee)!.name
        cell.desc.text = transaction.desc
        cell.date.text = transaction.date
        cell.total.text = String(NSString(format: "$%.2f", transaction.amount))
        cell.share.text = String(NSString(format: "$%.2f", transaction.getShare(VariableManager.getID())))
        cell.split.text = "Split between \(transaction.split.count) members"

        return cell
    }

}
