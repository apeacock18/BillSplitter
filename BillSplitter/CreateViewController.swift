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
        fName.autocorrectionType = .no
        lName.autocorrectionType = .no
        username.autocorrectionType = .no
        email.autocorrectionType = .no
        password.autocorrectionType = .no
        password2.autocorrectionType = .no

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


    @IBAction func create(_ sender: UIButton) {
        create()
    }

    func create() {
        let name: String = username.text!.lowercased()
        let fNameText = fName.text!
        let lNameText = lName.text!
        let emailText = email.text!.lowercased()

        // Validate input
        if name.characters.count < 6 {
            let message = UIAlertController(title: "Username not long enough", message: "Your username must be at least 6 characters long.", preferredStyle: UIAlertControllerStyle.alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(message, animated: true, completion: nil)
            return
        }
        if fNameText.characters.count == 0 {
            let message = UIAlertController(title: "First name not entered", message: "Please enter a first name.", preferredStyle: UIAlertControllerStyle.alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(message, animated: true, completion: nil)
            return
        }
        if lNameText.characters.count == 0 {
            let message = UIAlertController(title: "Last name not entered", message: "Please enter a last name.", preferredStyle: UIAlertControllerStyle.alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(message, animated: true, completion: nil)
            return
        }
        if emailText.characters.count == 0 {
            let message = UIAlertController(title: "Email not entered", message: "Please enter an email.", preferredStyle: UIAlertControllerStyle.alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(message, animated: true, completion: nil)
            return
        }
        if password.text!.characters.count < 8 {
            let message = UIAlertController(title: "Password not long enough", message: "Your password must be at least 8 characters long.", preferredStyle: UIAlertControllerStyle.alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(message, animated: true, completion: nil)
            return
        }
        if password.text! != password2.text! {
            let message = UIAlertController(title: "Passwords do not match", message: "Your passwords must match.", preferredStyle: UIAlertControllerStyle.alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(message, animated: true, completion: nil)
            return
        }

        // Query server

        NetworkManager.createNewUser(username: name,
                                     password: password.text!.hashWithSalt(salt: name),
                                     email: emailText,
                                     phoneNumber: "".lowercased(),
                                     firstName: fNameText,
                                     lastName: lNameText
        ) {
            (result: Int) in
            if result == 0 {
                VariableManager.setName(name: fNameText + " " + lNameText)
                VariableManager.setEmail(email: self.email.text!.lowercased())
                VariableManager.setUsername(username: self.username.text!.lowercased())
                VariableManager.setPhoneNumber(phoneNumber: "".lowercased()); // TODO: Add phone number field
                VariableManager.setAvatar(image: UIImage(named: "default")!)

                OperationQueue.main.addOperation {
                    self.present(TabViewController(), animated: true, completion: nil)
                }
            } else if result == 2 { // Send an error, the username is taken
                let message = UIAlertController(title: "Username Taken", message: "Please choose another username.", preferredStyle: UIAlertControllerStyle.alert)
                message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(message, animated: true, completion: nil)
            } else {
                let message = UIAlertController(title: "Error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(message, animated: true, completion: nil)
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        username.resignFirstResponder()
        create()
        return true
    }

}
