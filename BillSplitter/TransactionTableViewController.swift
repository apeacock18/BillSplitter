//
//  TransactionTableViewController.swift
//  p2
//
//  Created by Andrew Peacock on 3/10/16.
//  Copyright © 2016 Andrew Peacock. All rights reserved.
//

import UIKit

class TransactionTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var transactions = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: .Custom)
        button.setTitle("+", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(20.0)
        button.frame = CGRectMake(0, 0, 100, 40)
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .Plain, target: self, action: #selector(TransactionTableViewController.onCreate))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.systemFontOfSize(40)], forState: .Normal)
        loadSampleTransactions()
    }
    
    func loadSampleTransactions() {
        let photo1 = UIImage(named: "dog1")!
        let t1 = Transaction(name: "Corgi Butt", photo: photo1, amount: 42.00)
        
        let photo2 = UIImage(named: "dog2")!
        let t2 = Transaction(name: "Doug Barkman", photo: photo2, amount: 42.00)
        
        let photo3 = UIImage(named: "dog3")!
        let t3 = Transaction(name: "Snowball", photo: photo3, amount: 0.0)
        
        let photo4 = UIImage(named: "default")!
        let t4 = Transaction(name: "Billy", photo: photo4, amount: 876.01)
        
        transactions += [t1, t2, t3, t4]
    }
    
    func onCreate() {
        let vc = LoginViewController()
        self.presentViewController(vc, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "TransactionTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TransactionTableViewCell

        let t = transactions[indexPath.row]
        
        cell.nameLabel.text = t.name
        cell.photoImageView.image = t.photo
        cell.amountLabel.text = String(format:"%f", t.amount)
        if(t.amount != 0.0) {
            cell.backgroundColor = UIColor.redColor()
        }

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
