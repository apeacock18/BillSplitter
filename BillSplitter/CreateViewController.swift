//
//  CreateViewController.swift
//  BillSplitter
//
//  Created by gomeow on 4/21/16.
//  Copyright © 2016 Andrew Peacock. All rights reserved.
//

import Parse
import UIKit

class CreateViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var password2: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        fName.autocorrectionType = .No
        lName.autocorrectionType = .No
        username.autocorrectionType = .No
        email.autocorrectionType = .No
        password.autocorrectionType = .No
        password2.autocorrectionType = .No

        fName.delegate = self
        lName.delegate = self
        username.delegate = self
        email.delegate = self
        password.delegate = self
        password2.delegate = self

        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func create(sender: UIButton) {
        create()
    }

    func create() {
        let name: String = username.text!.lowercaseString
        let fNameText = fName.text!
        let lNameText = lName.text!
        let emailText = email.text!.lowercaseString

        // Validate input
        if name.characters.count < 6 {
            let message = UIAlertController(title: "Username not long enough", message: "Your username must be at least 6 characters long.", preferredStyle: UIAlertControllerStyle.Alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(message, animated: true, completion: nil)
            return
        }
        if fNameText.characters.count == 0 {
            let message = UIAlertController(title: "First name not entered", message: "Please enter a first name.", preferredStyle: UIAlertControllerStyle.Alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(message, animated: true, completion: nil)
            return
        }
        if lNameText.characters.count == 0 {
            let message = UIAlertController(title: "Last name not entered", message: "Please enter a last name.", preferredStyle: UIAlertControllerStyle.Alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(message, animated: true, completion: nil)
            return
        }
        if emailText.characters.count == 0 {
            let message = UIAlertController(title: "Email not entered", message: "Please enter an email.", preferredStyle: UIAlertControllerStyle.Alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(message, animated: true, completion: nil)
            return
        }
        if password.text!.characters.count < 8 {
            let message = UIAlertController(title: "Password not long enough", message: "Your password must be at least 8 characters long.", preferredStyle: UIAlertControllerStyle.Alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(message, animated: true, completion: nil)
            return
        }
        if password.text! != password2.text! {
            let message = UIAlertController(title: "Passwords do not match", message: "Your passwords must match.", preferredStyle: UIAlertControllerStyle.Alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(message, animated: true, completion: nil)
            return
        }

        // Query server

        NetworkManager.createNewUser(name,
                                     password: password.text!.hashWithSalt(name),
                                     email: emailText,
                                     phoneNumber: "".lowercaseString,
                                     name: (fNameText + " " + lNameText)
        ) {
            (result: Int) in
            if result == 0 {
            } else if result == 1 { // Send an error, the username is taken
                let message = UIAlertController(title: "Username Taken", message: "Please choose another username.", preferredStyle: UIAlertControllerStyle.Alert)
                message.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(message, animated: true, completion: nil)
            } else { // Result = 2
                VariableManager.setName(fNameText + " " + lNameText)
                VariableManager.setEmail(self.email.text!.lowercaseString)
                VariableManager.setUsername(self.username.text!.lowercaseString)
                VariableManager.setPhoneNumber("".lowercaseString); // TODO: Add phone number field
                VariableManager.setAvatar(UIImage(named: "default")!)
                StorageManager.saveSelfData()
                
                self.presentViewController(TabViewController(), animated: true, completion: nil)
            }
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        username.resignFirstResponder()
        create()
        return true
    }

}
