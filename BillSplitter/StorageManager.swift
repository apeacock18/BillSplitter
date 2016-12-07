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

    static func saveToken() {
        UserDefaults.standard.set(VariableManager.getToken(), forKey: "token")
        UserDefaults.standard.synchronize()
    }

    static func loadToken() -> String? {
        if let token: String = UserDefaults.standard.object(forKey: "token") as? String {
            VariableManager.setToken(token: token)
            return token
        }
        return nil
    }

    static func eraseToken() {
        UserDefaults.standard.set(nil, forKey: "token")
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
