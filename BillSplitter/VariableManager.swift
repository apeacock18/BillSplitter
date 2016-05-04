//
//  VariableManager.swift
//  BillSplitter
//
//  Created by gomeow on 4/29/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import Foundation
import UIKit

class VariableManager {

    private static var id: String = ""
    private static var email: String = ""
    private static var phoneNumber: String = ""
    private static var fName: String = ""
    private static var lName: String = ""
    private static var username: String = ""

    private static var groups: Array<Group> = []


    private static var avatar: UIImage? = nil

    static func erase() {
        id = ""
        email = ""
        phoneNumber = ""
        fName = ""
        lName = ""
        username = ""
        groups = []
        avatar = nil
    }

    /* Group Data */

    static func addGroup(group: Group) {
        groups.append(group)
    }

    static func getGroups() -> Array<Group> {
        return groups
    }

    static func groupCount() -> Int {
        return groups.count
    }

    static func containsGroup(groupId: String) -> Bool {
        for group in groups {
            if group.getID() == groupId {
                return true
            }
        }
        return false
    }

    /* Self Data */

    static func getID() -> String {
        return id
    }

    static func setID(id: String) {
        self.id = id
    }

    static func getEmail() -> String {
        return email
    }

    static func setEmail(email: String) {
        self.email = email
    }

    static func getFName() -> String {
        return fName
    }

    static func setFName(fName: String) {
        self.fName = fName
    }

    static func getLName() -> String {
        return lName
    }

    static func setLName(lName: String) {
        self.lName = lName
    }

    static func getFullName() -> String {
        return self.fName + " " + self.lName
    }

    static func getPhoneNumber() -> String {
        return phoneNumber
    }

    static func setPhoneNumber(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }

    static func getUsername() -> String {
        return username
    }

    static func setUsername(username: String) {
        self.username = username
    }

    static func getAvatar() -> UIImage {
        if avatar != nil {
            return avatar!
        } else {
            return UIImage(named: "default")!
        }
    }

    static func setAvatar(image: UIImage) {
        self.avatar = image
    }
}