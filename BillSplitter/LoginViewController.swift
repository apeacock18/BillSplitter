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
        username.autocorrectionType = UITextAutocorrectionType.no
        username.delegate = self
        password.autocorrectionType = UITextAutocorrectionType.no
        password.delegate = self
        //Root View

        self.hideKeyboardWhenTappedAround()


        if let token = StorageManager.loadToken() {
            loginWithToken(token: token)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func login() {
        self.dismissKeyboard()
        if username.text!.characters.count == 0 {
            let message = UIAlertController(title: "Username not entered", message: "Please enter your username.", preferredStyle: UIAlertControllerStyle.alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(message, animated: true, completion: nil)
            return
        }
        if password.text!.characters.count == 0 {
            let message = UIAlertController(title: "Password not entered", message: "Please enter your password.", preferredStyle: UIAlertControllerStyle.alert)
            message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(message, animated: true, completion: nil)
            return
        }

        // Start loading screen
        let sv = SpinnerView()
        self.view.addSubview(sv.view)
        let name: String = username.text!.lowercased()
        NetworkManager.loginWithUsername(username: name, password: password.text!.lowercased().hashWithSalt(salt: name)) {
            (result: Bool) in
            if result {
                let delegate = UIApplication.shared.delegate as! AppDelegate

                let tabViewController = TabViewController()
                delegate.tabViewController = tabViewController

                self.present(delegate.tabViewController!, animated: true, completion: nil)

            } else {
                let message = UIAlertController(title: "Username/Password Incorrect", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(message, animated: true, completion: nil)
                sv.view.removeFromSuperview()
            }
        }
    }

    func loginWithToken(token: String) {
        // Start loading screen
        let sv = SpinnerView()
        self.view.addSubview(sv.view)
        NetworkManager.loginWithToken(token: token) {
            (result: Bool) in
            if result {
                let delegate = UIApplication.shared.delegate as! AppDelegate

                let tabViewController = TabViewController()
                delegate.tabViewController = tabViewController

                self.present(delegate.tabViewController!, animated: true, completion: nil)

            } else {
                let message = UIAlertController(title: "Login expired", message: "Please login.", preferredStyle: UIAlertControllerStyle.alert)
                message.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(message, animated: true, completion: nil)
                sv.view.removeFromSuperview()
            }
        }
    }

    @IBAction func login(_ sender: UIButton) {
        login()
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {  //delegate method
        username.resignFirstResponder()
        login()
        return true
    }


    @IBAction func register(_ sender: UIButton) {
        self.present(CreateViewController(), animated: true, completion: nil)
    }


    @IBAction func forgot(_ sender: UIButton) {
        // TODO
    }
    
}
