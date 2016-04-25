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

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Root View
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func login(sender: UIButton) {
        // TODO: Actually login
        self.presentViewController(TabViewController(), animated: true, completion: nil)
    }
    
    
    @IBAction func register(sender: UIButton) {
        self.presentViewController(CreateViewController(), animated: true, completion: nil)
        
    }

    
    @IBAction func forgot(sender: UIButton) {
    }
    
    
    func loadImages() {
        
        let query = PFQuery(className: "test")
        
        query.findObjectsInBackgroundWithBlock ({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (error == nil) {
                for object in objects! {
                    let imageFile = object.valueForKey("files") as! PFFile
                    imageFile.getDataInBackgroundWithBlock({
                        (imageData: NSData?, error: NSError?) -> Void in
                        if (error == nil) {
                            _ = UIImage(data: imageData!)
                            //self.testImage.image = image
                        }
                    })
                }
            }
        })
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
