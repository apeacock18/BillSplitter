//
//  ViewController.swift
//  p2
//
//  Created by Andrew Peacock on 3/10/16.
//  Copyright © 2016 Andrew Peacock. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    
    @IBAction func Register(sender: UIButton) {
        let vc = TabViewController()
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func login(sender: UIButton) {
        let vc = TabViewController()
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

