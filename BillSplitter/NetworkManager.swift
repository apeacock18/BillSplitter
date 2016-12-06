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
    static let baseUrl: String = "http://127.0.0.1:8000/"
    //static let baseUrl: String = "http://api.gomeow.info/"

    static func login(username: String, password: String, completion: @escaping (Bool) -> ()) {
        runRequest(urlFrag: "login/", params: ["username": username, "password": password]) {
            (data, error) -> Void in
            if error != nil {
                completion(false)
            }
            if data != nil {
                if let response = data!.jsonToDictionary() {
                    if let _ = response["Error"] {
                        completion(false)
                    } else {
                        let userId = String(response["id"] as! Int)
                        let username = response["username"] as! String
                        let token = response["token"] as! String
                        let firstName = response["firstName"] as! String
                        let lastName = response["lastName"] as! String
                        let email = response["email"] as! String
                        let phoneNumber = response["phoneNumber"] as! String
                        VariableManager.setID(id: String(userId))
                        VariableManager.setToken(token: token)
                        VariableManager.setUsername(username: username)
                        VariableManager.setName(name: firstName + " " + lastName)
                        VariableManager.setEmail(email: email)
                        VariableManager.setPhoneNumber(phoneNumber: phoneNumber)

                        // Groups
                        runRequest(urlFrag: "group/info/", params: ["token": token, "userId": userId]) {
                            (data, error) -> Void in
                            if error != nil {
                                completion(false)
                            }
                            if data != nil {
                                if let response = data!.jsonToDictionary() {
                                    if let _ = response["Error"] {
                                        // TODO?
                                    }
                                    completion(false)
                                } else if let response = data!.jsonToArray() {
                                    var usersToQueryFor: [String] = []
                                    for group in response as! [[String: Any]] {
                                        let groupId = String(group["id"] as! Int)
                                        let name = group["name"] as! String
                                        let statusStrings = group["status"] as! [[String:Any]]
                                        let memberInts = group["members"] as! [Int]
                                        var members: [String] = []

                                        for memberInt in memberInts {
                                            members.append(String(memberInt))
                                        }

                                        let transactionStrings = group["transactions"] as! [[String:Any]]
                                        var statuses: [Status] = []
                                        for statusString in statusStrings {
                                            statuses.append(Status(id: String(statusString["id"] as! Int),
                                                                   data: statusString["data"] as! [[String: AnyObject]]))
                                        }

                                        var transactions: [Transaction] = []
                                        for transactionString in transactionStrings {
                                            let split = transactionString["split"] as! [String:Int]

                                            transactions.append(Transaction(payee: String(transactionString["payee"] as! Int),
                                                                            amount: transactionString["amount"] as! Double,
                                                                            split: split,
                                                                            desc: transactionString["description"] as! String,
                                                                            date: transactionString["date"] as! String))
                                        }
                                        let groupObj = Group(
                                            id: groupId,
                                            name: name,
                                            members: members,
                                            statuses: statuses,
                                            transactions: transactions
                                        )

                                        VariableManager.addGroup(group: groupObj)
                                        usersToQueryFor += members
                                    }

                                    let noDuplicates = usersToQueryFor.removeDuplicates()
                                    if noDuplicates.count != 0 {
                                        do {
                                            let jsonData = try JSONSerialization.data(withJSONObject: noDuplicates, options: [])
                                            let json = String(data: jsonData, encoding: .utf8)!
                                            runRequest(urlFrag: "person/info/", params: ["token":VariableManager.getToken(), "userIds": json]) {
                                                (data, error) -> Void in
                                                if error != nil {
                                                    completion(false)
                                                }
                                                if data != nil {
                                                    if let response = data!.jsonToDictionary() {
                                                        if let _ = response["Error"] {
                                                            // TODO?
                                                        }
                                                        completion(false)
                                                    } else if let response = data!.jsonToArray() {
                                                        for person in response as! [[String:Any]] {
                                                            let username = person["username"] as! String
                                                            let first_name = person["first_name"] as! String
                                                            let last_name = person["last_name"] as! String
                                                            let email = person["email"] as! String
                                                            let phoneNumber = person["phoneNumber"] as! String
                                                            let id = String(person["id"] as! Int!)
                                                            let user = User(id: id, username: username, name: first_name + " " + last_name, email: email, phonenumber: phoneNumber)
                                                            VariableManager.addUser(user: user)
                                                        }
                                                        completion(true)

                                                        // Get avatars
                                                        for user in noDuplicates {
                                                            getAvatarFromServer(userId: user) {
                                                                (image) -> Void in
                                                                if image != nil {
                                                                VariableManager.addAvatarToUser(userId: user, avatar: image!)
                                                                }
                                                            }
                                                        }
                                                        delegate?.dataReloadNeeded()
                                                    }
                                                }
                                            }
                                        } catch let error {
                                            debug(o: error)
                                        }
                                    } else {
                                        completion(true)
                                    }
                                } else {
                                    completion(true)
                                }
                            }
                        }
                    }
                } else {
                    completion(false)
                }
            }
        }
    }

    static func createNewUser(username: String, password: String, email: String, phoneNumber: String, firstName: String, lastName: String, completion: @escaping (Int) -> ()) {
        runRequest(urlFrag: "person/create/", params: ["token": VariableManager.getToken(), "firstName": firstName, "lastName": lastName, "username": username, "email": email, "phoneNumber": phoneNumber, "password": password]) {
            (response, error) -> Void in
            if error != nil {
                completion(1)
            } else {
                let data = response!.jsonToDictionary()!
                if let error = data["Error"] as? [String:Any] {
                    let code = error["Code"] as! Int
                    completion(code)
                } else {
                    VariableManager.setID(id: String(data["id"] as! Int))
                    VariableManager.setToken(token: data["token"] as! String)
                    completion(0)
                }
            }
        }
    }

    static func getUser(userId: String, completion: @escaping (_ result: User?) -> Void) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: [userId], options: [])
            let json = String(data: jsonData, encoding: .utf8)!
            runRequest(urlFrag: "person/info/", params: ["token": VariableManager.getToken(), "userIds": json]) {
                (response, error) -> Void in
                if error != nil {
                    completion(nil)
                }
                if response != nil {
                    if let data = response!.jsonToDictionary() {
                        if let _ = data["Error"] {
                            // TODO?
                        }
                        completion(nil)
                    } else if let data = response!.jsonToArray() {
                        let person = (data as! [[String:Any]])[0]
                        let username = person["username"] as! String
                        let first_name = person["first_name"] as! String
                        let last_name = person["last_name"] as! String
                        let email = person["email"] as! String
                        let phoneNumber = person["phoneNumber"] as! String
                        let id = String(person["id"] as! Int!)
                        let user = User(id: id, username: username, name: first_name + " " + last_name, email: email, phonenumber: phoneNumber)
                        completion(user)
                    }
                }
            }
        } catch let error {
            debug(o: error)
        }
    }

    static func createGroup(name: String, completion: @escaping (_ result: String?) -> Void) {
        runRequest(urlFrag: "group/create/", params: ["token": VariableManager.getToken(), "name": name]) {
            (response, error) -> Void in
            if error != nil {

                completion(nil)
            } else {
                let data = response!.jsonToDictionary()!
                if let _ = data["Error"] {
                } else {
                    let id = data["id"] as! Int
                    completion(String(id))
                }
            }
        }
    }

    static func addUserToGroup(groupId: String, userId: String, completion: @escaping (_ result: Int) -> Void) {
        runRequest(urlFrag: "group/adduser/", params: ["token": VariableManager.getToken(), "groupId": groupId, "userId": userId]) {
            (response, error) -> Void in
            if error != nil {
                completion(-1)
            } else {
                let data = response!.jsonToDictionary()!
                if let error = data["Error"] as? [String:Any] {
                    let code = error["Code"] as! Int
                    completion(code)
                    // 6: User does not exist
                    // 7: User is already in group
                } else {
                    completion(0)
                }
            }
        }
    }

    static func refreshStatus(groupId: String, completion: @escaping () -> Void) {
        let group = VariableManager.getGroup(groupId: groupId)
        runRequest(urlFrag: "group/status/", params: ["token": VariableManager.getToken(), "groupId": groupId]) {
            (response, error) -> Void in
            if error != nil {
                completion()
            } else {
                let data = response!.jsonToDictionary()!
                if let _ = data["Error"] {
                    completion()
                } else {
                    let statusStrings = data["status"] as! [[String: AnyObject]]
                    var statuses: [Status] = []
                    for statusString in statusStrings {
                        statuses.append(Status(information: statusString))
                    }
                    runRequest(urlFrag: "transaction/history/", params: ["token":VariableManager.getToken(), "groupId":groupId]) {
                        (response, error) -> Void in
                        if error != nil {
                            completion()
                        } else {
                            let data = response!.jsonToDictionary()!
                            if let _ = data["Error"] {
                                completion()
                            } else {
                                let transactionStrings: [[String:Any]] = data["transactions"] as! [[String:Any]]
                                var transactions: [Transaction] = []
                                for transactionString in transactionStrings {
                                    let description = transactionString["description"] as! String
                                    let payee = String(transactionString["payee"] as! Int)
                                    let date = transactionString["date"] as! String
                                    let amount = transactionString["amount"] as! Double
                                    let split = transactionString["split"] as! [String: Int]
                                    let transaction = Transaction(payee: payee, amount: amount, split: split, desc: description, date: date)
                                    transactions.append(transaction)
                                }
                                group!.reload(statuses: statuses, transactions: transactions)
                                completion()
                            }
                        }
                    }
                }
            }
        }
    }


    static func removeUserFromGroup(groupId: String, userId: String, completion: @escaping (_ result: Bool) -> Void) {
        runRequest(urlFrag: "group/removeuser/", params: ["token":VariableManager.getToken(), "groupId": groupId, "userId": userId]) {
            (response, error) -> Void in
            if error != nil {
                completion(false)
            } else {
                let data = response!.jsonToDictionary()!
                if let _ = data["Error"] {
                    completion(false)
                } else {
                    if let result = data["Result"] {
                        if result as! String == "Success" {
                            completion(true)
                        }
                    }
                    completion(false)
                }
            }
        }
    }

    static func userExists(username: String, completion: @escaping (_ result: String?) -> Void) {
        runRequest(urlFrag: "person/exists/", params: ["token": VariableManager.getToken(), "username":username]) {
            (response, error) -> Void in
            if error != nil {
                completion(nil)
            } else {
                let data = response!.jsonToDictionary()!
                if let _ = data["Error"] {
                    completion(nil)
                } else {
                    let id = data["id"] as! Int
                    completion(String(id))
                }
            }
        }
    }

    static func newTransaction(groupId: String, payee: String, amount: Double, description: String, date: String, users: [String], completion: @escaping (_ result: Bool) -> Void) {

        var allUsers = users
        allUsers.append(VariableManager.getID())

        var split: [String: Double] = [:]
        for user in allUsers {
            split[String(user)] = 1 / Double(allUsers.count)
        }

        do {
            let jsonSplit = try JSONSerialization.data(withJSONObject: split, options: [])

            let params: [String:String] = ["groupId": String(groupId),
                                           "payee": payee,
                                           "amount": String(amount),
                                           "description": description,
                                           "split": String(data: jsonSplit, encoding: .utf8)!,
                                           "date": date]

            runRequest(urlFrag: "transaction/new/", params: params) {
                (data, error) -> Void in
                if data != nil && error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } catch let error {
            print(error)
        }
    }

    static func payBack(groupId: String, payFrom: String, payTo: String, amount: Double, completion: @escaping (Bool) -> ()) {
        runRequest(urlFrag: "transaction/payback/", params: ["token": VariableManager.getToken(), "groupId": groupId, "from": payFrom, "to": payTo, "amount": String(amount)]) {
            (response, error) -> Void in
            if error != nil {
                completion(false)
            } else {
                let data = response!.jsonToDictionary()!
                if let _ = data["Error"] {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }

    static func getAvatarFromServer(userId: String, completion: @escaping (UIImage?) -> ()) {
        runRequest(urlFrag: "person/avatar/", params: ["token":VariableManager.getToken(), "id":userId]) {
            (response, error) -> Void in
            if response != nil {
                let data = response!.jsonToDictionary()
                let imageDataBase64 = data!["image"]! as! String
                let imageData = Data(base64Encoded: imageDataBase64, options: .ignoreUnknownCharacters)!
                let image = UIImage(data: imageData)
                completion(image)
            } else {
                completion(nil)
            }
        }
    }

    static func sendAvatarToServer(image: UIImage) {
        let url = "person/imageupload/"
        let imageData = UIImageJPEGRepresentation(image, 1.0)!
        let base64string = imageData.base64EncodedString()
        let token = VariableManager.getToken()
        let params = ["image":["content-type": "image/jpeg", "file_data" : base64string],
                      "token": token] as [String : Any]
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: [])
            runRequest(urlFrag: url, body: data) {
                (data, error) -> Void in
            }
        } catch let error {
            print(error)
        }
    }


    static func runRequest(urlFrag: String, params: [String: String], completion:@escaping (String?, Error?) -> ()) {
        var postString = "?"
        for (key, value) in params {
            postString +=
                "&"
                + key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                + "="
                +  value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
        runRequest(urlFrag: urlFrag, body: postString.data(using: .utf8)!) {
            (data: String?, error: Error?) -> Void in
            completion(data, error)
        }
    }

    static func runRequest(urlFrag: String, body: Data, completion:@escaping (String?, Error?) -> ()) {
        var request = URLRequest(url: URL(string: self.baseUrl + urlFrag)!)
        request.httpMethod = "POST"
        request.httpBody = body
        URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let data = data, let dataString = String(data: data, encoding: String.Encoding.utf8) {
                if urlFrag != "person/avatar/" {
                    debug(o: urlFrag + ": " + dataString)
                } else {
                    debug(o: urlFrag)
                }
                completion(dataString, error)
            } else {
                completion(nil, error)
            }
            }.resume()
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
