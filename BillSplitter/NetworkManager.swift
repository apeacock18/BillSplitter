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

    static func login(username: String, password: String, completion: (result: Bool) -> Void) {
        PFCloud.callFunctionInBackground("login", withParameters: ["username":username, "password":password]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
                completion(result: false)
            }
            if response != nil {
                print(response)
                let userId = response as! String
                VariableManager.setID(userId)

                let query = PFQuery(className: "Users").whereKey("objectId", equalTo: userId)
                query.getFirstObjectInBackgroundWithBlock({
                    (object: PFObject?, error: NSError?) -> Void in
                    if error == nil {
                        VariableManager.setUsername(object!.valueForKey("username") as! String)
                        VariableManager.setEmail(object!.valueForKey("email") as! String)
                        VariableManager.setName(object!.valueForKey("name") as! String)
                        //VariableManager.setPhoneNumber(object!.valueForKey("phoneNumber") as! String)

                        let groups = object!.valueForKey("groups") as? Array<String>
                        print(groups)


                        let imageFile = object!.valueForKey("avatar") as? PFFile
                        if imageFile != nil {
                            imageFromData(imageFile!) {
                                (result: UIImage?) in
                                if result != nil {
                                    VariableManager.setAvatar(result!)
                                }
                                if groups != nil {
                                    getGroupDataFromServer(groups!) {
                                        (result: Bool) in
                                        completion(result: true)
                                    }
                                }
                            }
                        } else {
                            VariableManager.setAvatar(UIImage(named: "default")!)
                            if groups != nil {
                                getGroupDataFromServer(groups!) {
                                    (result: Bool) in
                                    completion(result: true)
                                }
                            }
                        }
                        StorageManager.saveSelfData()
                    }
                })
            }
        }
    }

    static func getGroupDataFromServer(groups: Array<String>, completion: (result: Bool) -> Void) {
        var queries: Array<PFQuery> = []
        for group in groups {
            queries.append(PFQuery(className: "Groups").whereKey("objectId", equalTo: group))
        }
        if queries.count > 0 {
            let query = PFQuery.orQueryWithSubqueries(queries)
            query.findObjectsInBackgroundWithBlock {
                (results: [PFObject]?, error: NSError?) -> Void in
                if error == nil && results != nil {
                    var users: Set<String> = []
                    for result in results! {
                        let members: Array<String> = result["members"] as! Array<String>
                        var statusObjects: Array<Status> = []
                        for json in (result["status"] as! Array<String>) {
                            statusObjects.append(Status(json: json)!)
                        }
                        let groupObj = Group(
                            id: result.objectId!,
                            name: result["name"] as! String,
                            members: members,
                            statuses: statusObjects
                        )
                        VariableManager.addGroup(groupObj)
                        for member in members {
                            users.insert(member)
                        }
                    }
                    var userQueries: Array<PFQuery> = []
                    for userId in users {
                        userQueries.append(PFQuery(className: "Users").whereKey("objectId", equalTo: userId))
                    }
                    let userQuery = PFQuery.orQueryWithSubqueries(userQueries)
                    userQuery.findObjectsInBackgroundWithBlock {
                        (results: [PFObject]?, error: NSError?) -> Void in
                        if error == nil && results != nil {
                            for result in results! {
                                let userObj = User(id: result.objectId!, username: result["username"] as! String, name: result["name"] as! String)
                                VariableManager.addUser(userObj)
                            }
                            StorageManager.saveGroupData()
                            completion(result: true)
                        } else {
                            print(error)
                        }
                    }
                } else {
                    completion(result: false)
                    print("getGroupDataFromServer error:")
                    print(error)
                }
            }
        } else {
            // TODO Possibly will need to manage local storage
            completion(result: true)
        }
    }

    static func createNewUser(username: String, password: String, email: String, phoneNumber: String, name: String, completion: (result: Int) -> Void) {
        PFCloud.callFunctionInBackground("create", withParameters: [
            "username": username,
            "password": password,
            "email": email,
            "phoneNumber": phoneNumber,
            "name": name,
            "groups": []
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
                completion(result: groupId)
            }
            if error != nil {
                print(error)
                completion(result: nil)
            }
        }
    }

    static func addUserToGroup(groupId: String, userId: String, completion: (result: Int) -> Void) {
        PFCloud.callFunctionInBackground("addUserToGroup", withParameters: ["userId": userId, "groupId": groupId]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if response != nil {
                completion(result: 0) // Success
            }
            if error != nil {
                print(error)
                let code = error!.userInfo["error"]
                if code != nil {
                    if (code as? Int) == 2 {
                        completion(result: 1)
                        return
                    }
                }
                completion(result: 2) // Error
            }
        }
    }

    static func refreshStatus(groupId: String, completion: () -> Void) {
        let group = VariableManager.getGroup(groupId)
        let query = PFQuery(className: "Groups")
        query.whereKey("objectId", equalTo: groupId)
        query.getFirstObjectInBackgroundWithBlock {
            (result: PFObject?, error: NSError?) -> Void in
            if result != nil {
                let jsonArray: [String] = result!.objectForKey("status") as! [String]
                var statuses: [Status] = []
                for json in jsonArray {
                    statuses.append(Status(json: json)!)
                }
                group!.reloadStatuses(statuses)
                completion()
            } else {
                print(error)
            }
        }
    }

    static func removeUserFromGroup(groupId: String, userId: String, completion: (result: Bool) -> Void) {
        PFCloud.callFunctionInBackground("removeUserFromGroup", withParameters: ["userId": userId, "groupId": groupId]) {
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

    static func userExists(username: String, completion: (result: String?) -> Void) {
        PFCloud.callFunctionInBackground("userIdFromUsername", withParameters: ["username": username]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
                completion(result: nil)
            }
            if response != nil {
                completion(result: response as? String)
            }
        }
    }


    static func sendAvatarToServer(image: UIImage) {
        let user = PFObject(className: "Users")
        user.objectId = VariableManager.getID()

        let imageData = UIImagePNGRepresentation(image)
        let imageFile: PFFile = PFFile(data: imageData!)!

        user.setObject(imageFile, forKey: "avatar")

        user.saveInBackground()
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