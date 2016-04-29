//
//  StorageManager.swift
//  BillSplitter
//
//  Created by gomeow on 4/29/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import Foundation
import UIKit


class StorageManager {
    
    /*
     * This function adds a user to the specified group.
     */
    func addUserToGroup(id: String, groupId: String) -> Bool {
        var groupData: [String:AnyObject] = NSUserDefaults.standardUserDefaults().objectForKey("groups") as! [String:AnyObject]
        var group: [String:AnyObject] = groupData[groupId] as! [String:AnyObject]
        var currentUsers: [String] = group["members"] as! [String]
        
        //let currentUsers: [String] = NSUserDefaults.standardUserDefaults().objectForKey("groups")[groupId]["members"] as! [String]
        
        // eg. ["groups"]["hfb435vgh4"]["members"] as! [String]
        
        if currentUsers.contains(id) {
            return false
        }
        
        currentUsers.append(id)
        group["members"] = currentUsers
        groupData[groupId] = group
        NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(groupData), forKey: "groups")
        return true
    }
    
    /*
     * This function removes a user from the specified group.
     */
    func removeUserFromGroup(id: String, groupId: String) -> Bool {
        var groupData: [String:AnyObject] = NSUserDefaults.standardUserDefaults().objectForKey("groups") as! [String:AnyObject]
        var group: [String:AnyObject] = groupData[groupId] as! [String:AnyObject]
        let currentUsers: [String] = group["members"] as! [String]
        
        //let currentUsers: [String] = NSUserDefaults.standardUserDefaults().objectForKey("groups")[groupId]["members"] as! [String]
        
        if currentUsers.contains(id) {
            return false
        }
        
        group["members"] = currentUsers.filter() {$0 != id}
        groupData[groupId] = group
        NSUserDefaults.standardUserDefaults().setObject(groupData, forKey: "groups")
        return true
    }
    
    
    
    /*
     * Self data below.
     */
    
    func recallSelfData() {
        let data: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey("selfData") as! [String: String]
        VariableManager.setID(data["id"]!)
        VariableManager.setEmail(data["email"]!)
        VariableManager.setFName(data["fName"]!)
        VariableManager.setLName(data["lName"]!)
        VariableManager.setPhoneNumber(data["phoneNumber"]!)
    }
    
    static func saveSelfData() {
        let data: [String: AnyObject] = [
            "id":VariableManager.getID(),
            "email": VariableManager.getEmail(),
            "fName": VariableManager.getFName(),
            "lName": VariableManager.getLName(),
            "phoneNumber": VariableManager.getPhoneNumber()
        ]
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "selfData")
    }
    
    
    func getAvatar() -> UIImage? {
        var currentImage = NSUserDefaults.standardUserDefaults().objectForKey("selfAvatar") as? UIImage
        if currentImage == nil {
            currentImage = UIImage(named: "default")!
        }
        return currentImage
    }
    
    func saveSelfAvatar(image: UIImage) -> Bool {
        let currentImage = NSUserDefaults.standardUserDefaults().objectForKey("selfAvatar") as? UIImage
        if currentImage == nil {
            return false
        }
        NSUserDefaults.standardUserDefaults().setObject(image, forKey: "selfAvatar")
        return true
    }
    
    func saveSelfLocal(fName: String, lName: String, username: String, email: String) {
        let data = [
            "fName": fName,
            "lName": lName,
            "username": username,
            "email": email
        ]
        
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(data), forKey: "selfData")
        defaults.synchronize()
        
    }
    
    
}