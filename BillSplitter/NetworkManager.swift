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

    static func createNewUser(username: String, password: String, email: String, phoneNumber: String, fName: String, lName: String, completion: (result: Int) -> Void) {
        PFCloud.callFunctionInBackground("create", withParameters: [
            "username": username,
            "password": password,
            "email": email,
            "phoneNumber": phoneNumber,
            "fName": fName,
            "lName": lName
        ]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if response != nil {
                print("Create User Response: " + (response as! String))
                VariableManager.setID(response as! String)
                completion(result: 2)
            }
            if error != nil {
                let errorCode: Int = error!.userInfo["error"] as! Int
                /*
                 * Error Codes:
                 * 0: Unknown error
                 * 1: Username already taken
                 */
                completion(result: errorCode)
                print("Create User Error: " + String(errorCode))
            }
        }
    }

    static func createGroup(name: String, completion: (result: String?) -> Void) {
        PFCloud.callFunctionInBackground("createGroup", withParameters: ["name": name]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if response != nil {
                print(response)
                let groupId = response as! String
                addUserToGroup(groupId, userId: VariableManager.getID()) {
                    (result: Bool) in
                    if result {
                        // TODO Modify local storage
                    }
                }
                completion(result: groupId)
            }
            if error != nil {
                print(error)
                completion(result: nil)
            }
        }
    }

    static func addUserToGroup(groupId: String, userId: String, completion: (result: Bool) -> Void) {
        PFCloud.callFunctionInBackground("addUserToGroup", withParameters: ["userId": userId, "groupId": groupId]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if response != nil {
                print(response)
                completion(result: true)
            }
            if error != nil {
                print(error)
                completion(result: false)
            }
        }
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