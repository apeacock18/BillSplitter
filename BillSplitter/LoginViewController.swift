//
//  LoginViewController.swift
//  BillSplitter
//
//  Created by gomeow on 4/21/16.
//  Copyright © 2016 Andrew Peacock. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {


    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        username.autocorrectionType = UITextAutocorrectionType.No
        password.autocorrectionType = UITextAutocorrectionType.No
        //Root View



    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func login(sender: UIButton) {
        // TODO: Actually login
        //self.presentViewController(TabViewController(), animated: true, completion: nil)

        let name: String = username.text!.lowercaseString
        NetworkManager.login(
            name,
            password: password.text!.lowercaseString.hashWithSalt(name)
        )
    }


    @IBAction func register(sender: UIButton) {
        self.presentViewController(CreateViewController(), animated: true, completion: nil)

    }


    @IBAction func forgot(sender: UIButton) {
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
