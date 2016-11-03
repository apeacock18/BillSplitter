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

    static func login(username: String, password: String, completion: @escaping (Bool) -> ()) {
        PFCloud.callFunction(inBackground: "login", withParameters: ["username":username, "password":password]) {
            (response: Any?, error: Error?) -> Void in
            if error != nil {
                debug(o: error)
                completion(false)
            }
            if response != nil {
                debug(o: response)
                let userId = response as! String
                VariableManager.setID(id: userId)

                let query = PFQuery(className: "Users").whereKey("objectId", equalTo: userId)
                query.getFirstObjectInBackground(block: {
                    (object: PFObject?, error: Error?) -> Void in
                    if error == nil {
                        VariableManager.setUsername(username: object!.value(forKey: "username") as! String)
                        VariableManager.setEmail(email: object!.value(forKey: "email") as! String)
                        VariableManager.setName(name: object!.value(forKey: "name") as! String)
                        //VariableManager.setPhoneNumber(object!.valueForKey("phoneNumber") as! String)

                        let groups = object!.value(forKey: "groups") as? Array<String>
                        debug(o: groups)


                        let imageFile = object!.value(forKey: "avatar") as? PFFile
                        if imageFile != nil {
                            imageFromData(file: imageFile!) {
                                (result: UIImage?) in
                                if result != nil {
                                    VariableManager.setAvatar(image: result!)
                                }
                                if groups != nil {
                                    getGroupDataFromServer(groups: groups!) {
                                        (result: Bool) in
                                        completion(true)
                                    }
                                }
                            }
                        } else {
                            VariableManager.setAvatar(image: UIImage(named: "default")!)
                            if groups != nil {
                                getGroupDataFromServer(groups: groups!) {
                                    (result: Bool) in
                                    completion(true)
                                }
                            }
                        }
                        StorageManager.saveSelfData()
                    }
                })
            }
        }
    }

    static func getGroupDataFromServer(groups: Array<String>, completion: @escaping (Bool) -> ()) {
        var queries: Array<PFQuery<PFObject>> = []
        for group in groups {
            queries.append(PFQuery(className: "Groups").whereKey("objectId", equalTo: group))
        }
        if queries.count > 0 {
            let query = PFQuery.orQuery(withSubqueries: queries)
            query.findObjectsInBackground {
                (results: [PFObject]?, error: Error?) -> Void in
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
                        VariableManager.addGroup(group: groupObj)
                        for member in members {
                            users.insert(member)
                        }
                    }
                    var userQueries: Array<PFQuery<PFObject>> = []
                    for userId in users {
                        userQueries.append(PFQuery(className: "Users").whereKey("objectId", equalTo: userId))
                    }
                    let userQuery = PFQuery.orQuery(withSubqueries: userQueries)

                    var usersWithAvatars: [String:PFFile?] = [:]

                    userQuery.findObjectsInBackground {
                        (results: [PFObject]?, error: Error?) -> Void in
                        if error == nil && results != nil {
                            for result in results! {
                                let userObj = User(id: result.objectId!, username: result["username"] as! String, name: result["name"] as! String)
                                VariableManager.addUser(user: userObj)
                                let imageFile = result.value(forKey: "avatar") as? PFFile
                                if imageFile != nil {
                                    usersWithAvatars[result.objectId!] = imageFile
                                }
                            }
                            StorageManager.saveGroupData()
                            completion(true)
                            for (id, file) in usersWithAvatars {
                                imageFromData(file: file!) {
                                    (result: UIImage?) in
                                    if result != nil {
                                        VariableManager.addAvatarToUser(userId: id, avatar: result!)
                                    }
                                }
                            }
                            delegate?.dataReloadNeeded()
                        } else {
                            debug(o: error)
                        }
                    }
                } else {
                    completion(false)
                    debug(o: "getGroupDataFromServer error:")
                    debug(o: error)
                }
            }
        } else {
            completion(true)
        }
    }

    static func createNewUser(username: String, password: String, email: String, phoneNumber: String, name: String, completion: @escaping (Int) -> ()) {
        PFCloud.callFunction(inBackground: "create", withParameters: [
            "username": username,
            "password": password,
            "email": email,
            "phoneNumber": phoneNumber,
            "name": name,
            "groups": []
        ]) {
            (response: Any?, error: Error?) -> Void in
            if response != nil {
                debug(o: "Create User Response: " + (response as! String))
                VariableManager.setID(id: response as! String)
                completion(2)
            }
            if error != nil {

                let errorCode: Int = (error! as NSError).userInfo["error"] as! Int
                /*
                 * Error Codes:
                 * 0: Unknown error
                 * 1: Username already taken
                 */
                completion(errorCode)
                debug(o: "Create User Error: " + String(errorCode))
            }
        }
    }

    static func getUser(userId: String, completion: @escaping (_ result: User?) -> Void) {
        let query = PFQuery(className: "Users")
        query.whereKey("objectId", equalTo: userId)
        query.getFirstObjectInBackground {
            (result: PFObject?, error: Error?) -> Void in
            if result != nil && error == nil {
                let name = result!["name"] as! String
                let username = result!["username"] as! String
                let imageFile = result!["avatar"] as? PFFile
                var user: User?
                if imageFile != nil {
                    imageFromData(file: imageFile!) {
                        (result: UIImage?) in
                        if result != nil {
                            user = User(id: userId, username: username, name: name, avatar: result!)
                        } else {
                            user = User(id: userId, username: username, name: name)
                        }
                        completion(user)
                    }
                } else {
                    user = User(id: userId, username: username, name: name)
                    completion(user)
                }
            } else {
                completion(nil)
            }
        }
    }

    static func createGroup(name: String, completion: @escaping (_ result: String?) -> Void) {
        PFCloud.callFunction(inBackground: "createGroup", withParameters: ["name": name]) {
            (response: Any?, error: Error?) -> Void in
            if response != nil {
                debug(o: response)
                let groupId = response as! String
                completion(groupId)
            }
            if error != nil {
                debug(o: error)
                completion(nil)
            }
        }
    }

    static func addUserToGroup(groupId: String, userId: String, completion: @escaping (_ result: Int) -> Void) {
        PFCloud.callFunction(inBackground: "addUserToGroup", withParameters: ["userId": userId, "groupId": groupId]) {
            (response: Any?, error: Error?) -> Void in
            if response != nil {
                completion(0) // Success
            }
            if error != nil {
                debug(o: error)
                let code = (error! as NSError).userInfo["error"]
                if code != nil {
                    if (code as? Int) == 2 {
                        completion(1)
                        return
                    }
                }
                completion(2) // Error
            }
        }
    }

    static func refreshStatus(groupId: String, completion: @escaping () -> Void) {
        let group = VariableManager.getGroup(groupId: groupId)
        let query = PFQuery(className: "Groups")
        query.whereKey("objectId", equalTo: groupId)
        query.getFirstObjectInBackground {
            (result: PFObject?, error: Error?) -> Void in
            if result != nil {
                let statusArray: [String] = result!.object(forKey: "status") as! [String]
                let transactionArray: [String] = result!.object(forKey: "transactions") as! [String]
                var statuses: [Status] = []
                var transactions: [Transaction] = []
                for json in statusArray {
                    statuses.append(Status(json: json)!)
                }
                for json in transactionArray {
                    transactions.append(Transaction(json: json)!)
                }
                group!.reload(statuses: statuses, transactions: transactions)
                completion()
            } else {
                debug(o: error)
            }
        }
    }

    static func removeUserFromGroup(groupId: String, userId: String, completion: @escaping (_ result: Bool) -> Void) {
        PFCloud.callFunction(inBackground: "removeUserFromGroup", withParameters: ["userId": userId, "groupId": groupId]) {
            (response: Any?, error: Error?) -> Void in
            if response != nil {
                debug(o: response)
                completion(true)
            }
            if error != nil {
                debug(o: error)
                completion(false)
            }
        }
    }

    static func userExists(username: String, completion: @escaping (_ result: String?) -> Void) {
        PFCloud.callFunction(inBackground: "userIdFromUsername", withParameters: ["username": username]) {
            (response: Any?, error: Error?) -> Void in
            if error != nil {
                debug(o: error)
                completion(nil)
            }
            if response != nil {
                completion(response as? String)
            }
        }
    }

    static func newTransaction(groupId: String, payee: String, amount: Double, description: String, date: String, users: [String], completion: @escaping (_ result: Bool) -> Void) {
        var allUsers = users
        allUsers.append(VariableManager.getID())

        var split: [String: Double] = [:]
        for user in allUsers {
            split[user] = 1 / Double(allUsers.count)
        }

        PFCloud.callFunction(inBackground: "newTransaction", withParameters: [
            "groupId": groupId,
            "payee": payee,
            "amount": amount,
            "description": description,
            "date": date,
            "split": split
        ]) {
            (response: Any?, error: Error?) -> Void in
            if response != nil && error == nil {
                completion(true)
                debug(o: response)
            } else {
                completion(false)
                debug(o: error)
            }
        }
    }

    static func payBack(groupId: String, payFrom: String, payTo: String, amount: Double, completion: @escaping (Bool) -> ()) {
        PFCloud.callFunction(inBackground: "payBack", withParameters: [
            "groupId": groupId,
            "payFrom": payFrom,
            "payTo": payTo,
            "amount": amount
        ]) {
            (response: Any?, error: Error?) -> Void in
            if response != nil && error == nil {
                debug(o: response)
                completion(true)
            } else {
                debug(o: error)
                completion(false)
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


    static func dothis(completion: (_ result: Bool) -> Void)  {

    }

    static func imageFromData(file: PFFile, completion:@escaping (UIImage?) -> ()) {
        file.getDataInBackground(block: {
            (imageData: Data?, error: Error?) -> Void in
            if error == nil {
                completion(UIImage(data: imageData!))
            }
        })
    }

    static func debug(o: Any?) {
        if verbose {
            if o != nil {
                print(o!)
            } else {
                print(o)
            }
        }
    }

}
