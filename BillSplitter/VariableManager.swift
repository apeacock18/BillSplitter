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
    private static var name: String = ""
    private static var username: String = ""

    private static var groups: Array<Group> = []

    private static var users: Array<User> = []

    private static var token: String = ""

    private static var avatar: UIImage? = nil

    static func erase() {
        id = ""
        email = ""
        phoneNumber = ""
        name = ""
        username = ""
        groups = []
        users = []
        avatar = nil
    }

    /* User Data */

    static func getUsers() -> Array<User> {
        return users
    }

    static func getUserById(id: String) -> User? {
        for user in users {
            if user.id == id {
                return user
            }
        }
        return nil
    }

    static func getUserByName(username: String) -> User? {
        for user in users {
            if user.username == username {
                return user
            }
        }
        return nil
    }

    static func addUser(user: User) {
        if !containsUser(userId: user.id) {
            users.append(user)
        }
    }

    static func containsUser(userId: String) -> Bool {
        for user in users {
            if user.id == userId {
                return true
            }
        }
        return false
    }

    /* Group Data */

    static func addGroup(group: Group) {
        groups.append(group)
    }

    static func getGroups() -> Array<Group> {
        return groups
    }

    static func getGroup(groupId: String) -> Group? {
        for group in groups {
            if group.getID() == groupId {
                return group
            }
         }
        return nil
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

    static func addUserToGroup(userId: String, groupId: String) {
        for group in groups {
            if group.getID() == groupId {
                group.addMember(userId: userId)
            }
        }
    }

    static func addAvatarToUser(userId: String, avatar: UIImage) {
        if userId == id {
            self.avatar = avatar
        } else {
            for user in users {
                if user.id == userId {
                    user.setAvatar(image: avatar)
                }
            }
        }
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

    static func getName() -> String {
        return name
    }

    static func setName(name: String) {
        self.name = name
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

    static func getToken() -> String {
        return token
    }

    static func setToken(token: String) {
        self.token = token
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

    static func reloadGroups(completion: @escaping (Bool) -> ()) {
        groups = []
        users = []
        NetworkManager.getGroupData() {
            (result) -> Void in
            completion(result)
        }
    }
}
