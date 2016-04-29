//
//  NetworkManager.swift
//  BillSplitter
//
//  Created by gomeow on 4/29/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import Foundation
import UIKit
import Parse

class NetworkManager {
    
    static func login(username: String, password: String) -> Bool {
        
        
        
        let query = PFQuery(className: "Users").whereKey("username", equalTo: username)
        query.getFirstObjectInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                VariableManager.setID(object!.valueForKey("id") as! String)
                VariableManager.setEmail(object!.valueForKey("email") as! String)
                VariableManager.setFName(object!.valueForKey("fName") as! String)
                VariableManager.setLName(object!.valueForKey("lName") as! String)
                VariableManager.setPhoneNumber(object!.valueForKey("phoneNumber") as! String)
                
                let imageFile = object!.valueForKey("avatar") as! PFFile
                imageFromData(imageFile) {
                    (result: UIImage?) in
                    if result != nil {
                        VariableManager.setAvatar(result!)
                    }
                }
                
                StorageManager.saveSelfData()
            }
        })
        
        return true
    }
    
    
    static func imageFromData(file: PFFile, completion: (result: UIImage?) -> Void) {
        file.getDataInBackgroundWithBlock({
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                completion(result: UIImage(data: imageData!))
            }
        })
    }
    
}