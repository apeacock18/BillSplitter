//
//  User.swift
//  BillSplitter
//
//  Created by gomeow on 5/7/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class User {

    private var avatar: UIImage?

    var username: String
    var id: String
    var name: String
    var email: String
    var phonenumber: String

    init(id: String, username: String, name: String) {
        self.id = id
        self.username = username
        self.name = name
        self.email = ""
        self.phonenumber = ""
    }

    init(id: String, username: String, name: String, email: String, phonenumber: String) {
        self.id = id
        self.username = username
        self.name = name
        self.email = email
        self.phonenumber = phonenumber
    }

    init(id: String, username: String, name: String, avatar: UIImage) {
        self.id = id
        self.username = username
        self.name = name
        self.email = ""
        self.phonenumber = ""
        self.avatar = avatar
    }

    func getAvatar() -> UIImage {
        if avatar != nil {
            return avatar!
        } else {
            return UIImage(named: "default")!
        }
    }

    func setAvatar(image: UIImage) {
        avatar = image
    }

}
