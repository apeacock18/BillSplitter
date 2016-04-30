//
//  CreateViewController.swift
//  BillSplitter
//
//  Created by gomeow on 4/21/16.
//  Copyright © 2016 Andrew Peacock. All rights reserved.
//

import Parse
import UIKit

class CreateViewController: UIViewController {

    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fName.autocorrectionType = UITextAutocorrectionType.No
        lName.autocorrectionType = UITextAutocorrectionType.No
        username.autocorrectionType = UITextAutocorrectionType.No
        email.autocorrectionType = UITextAutocorrectionType.No
        password.autocorrectionType = UITextAutocorrectionType.No
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func create(sender: UIButton) {
        let name: String = username.text!.lowercaseString
        let exists: Bool = NetworkManager.createNewUser(name,
            password: password.text!.lowercaseString.hashWithSalt(name),
            email: email.text!.lowercaseString,
            phoneNumber: "".lowercaseString,
            fName: fName.text!.lowercaseString,
            lName: lName.text!.lowercaseString
        )
        
        if exists {
            // Send an error, the username is taken
        } else {
            VariableManager.setFName(fName.text!.lowercaseString)
            VariableManager.setLName(lName.text!.lowercaseString)
            VariableManager.setEmail(email.text!.lowercaseString)
            VariableManager.setUsername(username.text!.lowercaseString)
            VariableManager.setPhoneNumber("".lowercaseString); // TODO: Add phone number field
            StorageManager.saveSelfData()
            
            self.presentViewController(TabViewController(), animated: true, completion: nil)
        }
    }

}
