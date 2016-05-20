//
//  LoginViewController.swift
//  BillSplitter
//
//  Created by gomeow on 4/21/16.
//  Copyright © 2016 Andrew Peacock. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        username.autocorrectionType = UITextAutocorrectionType.No
        username.delegate = self
        password.autocorrectionType = UITextAutocorrectionType.No
        password.delegate = self
        //Root View

        self.hideKeyboardWhenTappedAround()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func login(sender: UIButton) {
        login()
    }

    func login() {
        self.dismissKeyboard()
        if username.text!.characters.count == 0 {
            let message = UIAlertController(title: "Username not entered", message: "Please enter your username.", preferredStyle: UIAlertControllerStyle.Alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(message, animated: true, completion: nil)
            return
        }
        if password.text!.characters.count == 0 {
            let message = UIAlertController(title: "Password not entered", message: "Please enter your password.", preferredStyle: UIAlertControllerStyle.Alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(message, animated: true, completion: nil)
            return
        }

        // Start loading screen
        let sv = SpinnerView()
        self.view.addSubview(sv.view)
        let name: String = username.text!.lowercaseString
        NetworkManager.login(name, password: password.text!.lowercaseString.hashWithSalt(name)) {
            (result: Bool) in
            sv.view.removeFromSuperview() // Remove loading screen
            if result {
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                delegate.tabViewController = TabViewController()
                self.presentViewController(delegate.tabViewController!, animated: true, completion: nil)
            } else {
                let message = UIAlertController(title: "Username/Password Incorrect", message: "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                message.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(message, animated: true, completion: nil)
            }
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        username.resignFirstResponder()
        login()
        return true
    }


    @IBAction func register(sender: UIButton) {
        self.presentViewController(CreateViewController(), animated: true, completion: nil)
    }
    
}
