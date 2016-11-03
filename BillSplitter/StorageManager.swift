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
        if UserDefaults.standard.object(forKey: "groups") != nil {
            var groupData: [String:Any] = UserDefaults.standard.object(forKey: "groups") as! [String:Any]
            groupData[id] = ["name": name, "members": []]
            UserDefaults.standard.set(groupData, forKey: "groups")

        } else {
            let groupData: [String: Any] = [id: ["name": name, "members": []]]
            UserDefaults.standard.set(groupData, forKey: "groups")
        }
        UserDefaults.standard.synchronize()
    }


    /*
     * This function adds a user to the specified group.
     */
    @discardableResult
    static func addUserToGroup(id: String, groupId: String) -> Bool {
        var groupData: [String:AnyObject] = UserDefaults.standard.object(forKey: "groups") as! [String:AnyObject]
        var group: [String:AnyObject] = groupData[groupId] as! [String:AnyObject]
        var currentUsers: [String] = group["members"] as! [String]

        //let currentUsers: [String] = NSUserDefaults.standardUserDefaults().objectForKey("groups")[groupId]["members"] as! [String]

        // eg. ["groups"]["hfb435vgh4"]["members"] as! [String]

        if currentUsers.contains(id) {
            return false
        }

        currentUsers.append(id)
        group["members"] = currentUsers as AnyObject?
        groupData[groupId] = group as AnyObject?
        UserDefaults.standard.set(groupData, forKey: "groups")
        UserDefaults.standard.synchronize()
        return true
    }

    /*
     * This function removes a user from the specified group.
     */
    static func removeUserFromGroup(id: String, groupId: String) -> Bool {
        var groupData: [String:AnyObject] = UserDefaults.standard.object(forKey: "groups") as! [String:AnyObject]
        var group: [String:Any] = groupData[groupId] as! [String:Any]
        let currentUsers: [String] = group["members"] as! [String]

        //let currentUsers: [String] = NSUserDefaults.standardUserDefaults().objectForKey("groups")[groupId]["members"] as! [String]

        if currentUsers.contains(id) {
            return false
        }

        group["members"] = currentUsers.filter() {$0 != id}
        groupData[groupId] = group as AnyObject?
        UserDefaults.standard.set(groupData, forKey: "groups")
        UserDefaults.standard.synchronize()
        return true
    }

    static func recallGroupData() {

    }

    static func saveGroupData() {
        var data: [String: AnyObject] = [:]
        for group in VariableManager.getGroups() {
            let groupData: [String: AnyObject] = [
                "name": group.getName() as AnyObject,
                "members": group.getMembers() as AnyObject
            ]
            data[group.getID()] = groupData as AnyObject?
        }
        UserDefaults.standard.set(data, forKey: "groups")
        UserDefaults.standard.synchronize()
    }



    /*
     * Self data below.
     */

    static func recallSelfData() {
        if let data: [String: String] = UserDefaults.standard.object(forKey: "selfData") as? [String: String] {
            VariableManager.setID(id: data["id"]!)
            VariableManager.setEmail(email: data["email"]!)
            VariableManager.setName(name: data["name"]!)
            VariableManager.setPhoneNumber(phoneNumber: data["phoneNumber"]!)
            getAvatar()
        }
    }

    static func saveSelfData() {
        let data: [String: AnyObject] = [
            "id":VariableManager.getID() as AnyObject,
            "email": VariableManager.getEmail() as AnyObject,
            "name": VariableManager.getName() as AnyObject,
            "phoneNumber": VariableManager.getPhoneNumber() as AnyObject
        ]
        UserDefaults.standard.set(data, forKey: "selfData")
        UserDefaults.standard.synchronize()
    }


    @discardableResult
    static func getAvatar() -> UIImage? {
        var currentImage = UserDefaults.standard.object(forKey: "selfAvatar") as? UIImage
        if currentImage == nil {
            currentImage = UIImage(named: "default")!
        }
        return currentImage
    }

    @discardableResult
    static func saveSelfAvatar(image: UIImage) -> Bool {
        let currentImage = UserDefaults.standard.object(forKey: "selfAvatar") as? UIImage
        if currentImage == nil {
            return false
        }
        UserDefaults.standard.set(image, forKey: "selfAvatar")
        UserDefaults.standard.synchronize()
        return true
    }


}
