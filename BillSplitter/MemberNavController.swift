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
        memberController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Options", style: .Plain, target: self, action: #selector(MemberNavController.options))

        self.viewControllers = [memberController]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func options() {
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
                if text == nil || text == "" {

                } else {
                    print(text!)
                    PFCloud.callFunctionInBackground("userIdFromUsername", withParameters: ["username": text!]) {
                        (response: AnyObject?, error: NSError?) -> Void in
                        if error != nil {
                            print(error)
                        }
                        if response != nil {
                            print(response)
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
