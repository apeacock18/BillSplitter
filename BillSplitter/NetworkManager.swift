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
        PFCloud.callFunctionInBackground("login", withParameters: ["username":username, "password":password]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            }
            if response != nil {
                print(response)
            }
        }
        
        /*
         * TODO: Refresh local cache
         *
         
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
        })*/
        
        return true
    }
    
    static func createNewUser(username: String, password: String, email: String, phoneNumber: String, fName: String, lName: String) -> Bool {
        PFCloud.callFunctionInBackground("create", withParameters: [
            "username":username,
            "password": password,
            "email": email,
            "phoneNumber": phoneNumber,
            "fName": fName,
            "lName": lName
        ]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if response != nil {
                print(response)
                // TODO: VariableManager.setID(response as! String)
            }
            if error != nil {
                print(error!.code)
                let errorCode: Int = error!.userInfo["error"] as! Int
                if errorCode == 1 { // Username already taken
                    // TODO: Implement a completion handler
                }
                print(errorCode)
            }
        }
        
        
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