//
//  NetworkManager.swift
//  BillSplitter
//
//  Created by gomeow on 4/29/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit
import Parse

class NetworkManager {

    static let verbose = true

    static var delegate: ReloadDelegate?

    static func login(username: String, password: String, completion: (result: Bool) -> Void) {
        PFCloud.callFunctionInBackground("login", withParameters: ["username":username, "password":password]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                debug(error)
                completion(result: false)
            }
            if response != nil {
                debug(response)
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
                        debug(groups)


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
                        var transactionObjects: Array<Transaction> = []
                        for json in (result["status"] as! Array<String>) {
                            statusObjects.append(Status(json: json)!)
                        }
                        for json in (result["transactions"] as! Array<String>) {
                            transactionObjects.append(Transaction(json: json)!)
                        }
                        let groupObj = Group(
                            id: result.objectId!,
                            name: result["name"] as! String,
                            members: members,
                            statuses: statusObjects,
                            transactions: transactionObjects
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

                    var usersWithAvatars: [String:PFFile?] = [:]

                    userQuery.findObjectsInBackgroundWithBlock {
                        (results: [PFObject]?, error: NSError?) -> Void in
                        if error == nil && results != nil {
                            for result in results! {
                                let userObj = User(id: result.objectId!, username: result["username"] as! String, name: result["name"] as! String)
                                VariableManager.addUser(userObj)
                                let imageFile = result.valueForKey("avatar") as? PFFile
                                if imageFile != nil {
                                    usersWithAvatars[result.objectId!] = imageFile
                                }
                            }
                            StorageManager.saveGroupData()
                            completion(result: true)
                            for (id, file) in usersWithAvatars {
                                imageFromData(file!) {
                                    (result: UIImage?) in
                                    if result != nil {
                                        VariableManager.addAvatarToUser(id, avatar: result!)
                                    }
                                }
                            }
                            delegate?.dataReloadNeeded()
                        } else {
                            debug(error)
                        }
                    }
                } else {
                    completion(result: false)
                    debug("getGroupDataFromServer error:")
                    debug(error)
                }
            }
        } else {
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
                debug("Create User Response: " + (response as! String))
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
                debug("Create User Error: " + String(errorCode))
            }
        }
    }

    static func getUser(userId: String, completion: (result: User?) -> Void) {
        let query = PFQuery(className: "Users")
        query.whereKey("objectId", equalTo: userId)
        query.getFirstObjectInBackgroundWithBlock {
            (result: PFObject?, error: NSError?) -> Void in
            if result != nil && error == nil {
                let name = result!["name"] as! String
                let username = result!["username"] as! String
                let imageFile = result!["avatar"] as? PFFile
                var user: User?
                if imageFile != nil {
                    imageFromData(imageFile!) {
                        (result: UIImage?) in
                        if result != nil {
                            user = User(id: userId, username: username, name: name, avatar: result!)
                        } else {
                            user = User(id: userId, username: username, name: name)
                        }
                        completion(result: user)
                    }
                } else {
                    user = User(id: userId, username: username, name: name)
                    completion(result: user)
                }
            } else {
                completion(result: nil)
            }
        }
    }

    static func createGroup(name: String, completion: (result: String?) -> Void) {
        PFCloud.callFunctionInBackground("createGroup", withParameters: ["name": name]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if response != nil {
                debug(response)
                let groupId = response as! String
                completion(result: groupId)
            }
            if error != nil {
                debug(error)
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
                debug(error)
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
                let statusArray: [String] = result!.objectForKey("status") as! [String]
                let transactionArray: [String] = result!.objectForKey("transactions") as! [String]
                var statuses: [Status] = []
                var transactions: [Transaction] = []
                for json in statusArray {
                    statuses.append(Status(json: json)!)
                }
                for json in transactionArray {
                    transactions.append(Transaction(json: json)!)
                }
                group!.reload(statuses, transactions: transactions)
                completion()
            } else {
                debug(error)
            }
        }
    }

    static func removeUserFromGroup(groupId: String, userId: String, completion: (result: Bool) -> Void) {
        PFCloud.callFunctionInBackground("removeUserFromGroup", withParameters: ["userId": userId, "groupId": groupId]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if response != nil {
                debug(response)
                completion(result: true)
            }
            if error != nil {
                debug(error)
                completion(result: false)
            }
        }
    }

    static func userExists(username: String, completion: (result: String?) -> Void) {
        PFCloud.callFunctionInBackground("userIdFromUsername", withParameters: ["username": username]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                debug(error)
                completion(result: nil)
            }
            if response != nil {
                completion(result: response as? String)
            }
        }
    }

    static func newTransaction(groupId: String, payee: String, amount: Double, description: String, date: String, users: [String], completion: (result: Bool) -> Void) {
        var allUsers = users
        allUsers.append(VariableManager.getID())

        var split: [String: Double] = [:]
        for user in allUsers {
            split[user] = 1 / Double(allUsers.count)
        }

        PFCloud.callFunctionInBackground("newTransaction", withParameters: [
            "groupId": groupId,
            "payee": payee,
            "amount": amount,
            "description": description,
            "date": date,
            "split": split
        ]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if response != nil && error == nil {
                completion(result: true)
                debug(response)
            } else {
                completion(result: false)
                debug(error)
            }
        }
    }

    static func payBack(groupId: String, payFrom: String, payTo: String, amount: Double, completion: (result: Bool) -> Void) {
        PFCloud.callFunctionInBackground("payBack", withParameters: [
            "groupId": groupId,
            "payFrom": payFrom,
            "payTo": payTo,
            "amount": amount
        ]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if response != nil && error == nil {
                debug(response)
                completion(result: true)
            } else {
                debug(error)
                completion(result: false)
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

    static func debug(o: AnyObject?) {
        if verbose {
            if o != nil {
                print(o!)
            } else {
                print(o)
            }
        }
    }

}