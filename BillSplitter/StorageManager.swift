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


    static func createGroup(id: String, name: String) {
        if NSUserDefaults.standardUserDefaults().objectForKey("groups") != nil {
            var groupData: [String:AnyObject] = NSUserDefaults.standardUserDefaults().objectForKey("groups") as! [String:AnyObject]
            groupData[id] = ["name": name, "members": []]
            NSUserDefaults.standardUserDefaults().setObject(groupData, forKey: "groups")

        } else {
            let groupData: [String: AnyObject] = [id: ["name": name, "members": []]]
            NSUserDefaults.standardUserDefaults().setObject(groupData, forKey: "groups")
        }
        NSUserDefaults.standardUserDefaults().synchronize()
    }


    /*
     * This function adds a user to the specified group.
     */
    static func addUserToGroup(id: String, groupId: String) -> Bool {
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
        NSUserDefaults.standardUserDefaults().setObject(groupData, forKey: "groups")
        NSUserDefaults.standardUserDefaults().synchronize()
        return true
    }

    /*
     * This function removes a user from the specified group.
     */
    static func removeUserFromGroup(id: String, groupId: String) -> Bool {
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
        NSUserDefaults.standardUserDefaults().synchronize()
        return true
    }

    static func recallGroupData() {

    }

    static func saveGroupData() {
        var data: [String: AnyObject] = [:]
        for group in VariableManager.getGroups() {
            let groupData: [String: AnyObject] = [
                "name": group.getName(),
                "members": group.getMembers()
            ]
            data[group.getID()] = groupData
        }
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "groups")
        NSUserDefaults.standardUserDefaults().synchronize()
    }



    /*
     * Self data below.
     */

    static func recallSelfData() {
        if let data: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey("selfData") as? [String: String] {
            VariableManager.setID(data["id"]!)
            VariableManager.setEmail(data["email"]!)
            VariableManager.setName(data["name"]!)
            VariableManager.setPhoneNumber(data["phoneNumber"]!)
            getAvatar()
        }
    }

    static func saveSelfData() {
        let data: [String: AnyObject] = [
            "id":VariableManager.getID(),
            "email": VariableManager.getEmail(),
            "name": VariableManager.getName(),
            "phoneNumber": VariableManager.getPhoneNumber()
        ]
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "selfData")
        NSUserDefaults.standardUserDefaults().synchronize()
    }


    static func getAvatar() -> UIImage? {
        var currentImage = NSUserDefaults.standardUserDefaults().objectForKey("selfAvatar") as? UIImage
        if currentImage == nil {
            currentImage = UIImage(named: "default")!
        }
        return currentImage
    }

    static func saveSelfAvatar(image: UIImage) -> Bool {
        let currentImage = NSUserDefaults.standardUserDefaults().objectForKey("selfAvatar") as? UIImage
        if currentImage == nil {
            return false
        }
        NSUserDefaults.standardUserDefaults().setObject(image, forKey: "selfAvatar")
        NSUserDefaults.standardUserDefaults().synchronize()
        return true
    }


}