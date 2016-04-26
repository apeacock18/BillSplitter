//
//  CreateViewController.swift
//  BillSplitter
//
//  Created by gomeow on 4/21/16.
//  Copyright © 2016 Andrew Peacock. All rights reserved.
//

import Parse
import UIKit
import CryptoSwift

class CreateViewController: UIViewController {

    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hash1(input: String, salt: String) -> String {
        var password: String = input
        password += salt
        return input.sha512()
    }
    
    func sendToServer(fName: String, lName: String, username: String, email: String, password: String) {
        let user = PFObject(className: "Users")
        user["fName"] = fName
        user["lName"] = lName
        user["username"] = username
        user["email"] = email
        user["password"] = password
        user.saveInBackground()
    }
    
    func saveSelfLocal(fName: String, lName: String, username: String, email: String) {
        let data = [
            "fName": fName,
            "lName": lName,
            "username": username,
            "email": email
        ]
        
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(data), forKey: "selfData")
        defaults.synchronize()
        
    }
    
    @IBAction func create(sender: UIButton) {
        
        // TODO: Check if already exists
        
        saveSelfLocal(fName.text!, lName: lName.text!, username: username.text!, email: email.text!)
        
        //sendToServer(fName.text!, lName: lName.text!, username: username.text!, email: email.text!, password: hash1(password.text!, salt: username.text!))
        self.presentViewController(TabViewController(), animated: true, completion: nil)
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
