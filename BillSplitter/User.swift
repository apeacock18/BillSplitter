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

    init(id: String, username: String) {
        self.id = id
        self.username = username
    }

    init(id: String, username: String, avatar: UIImage) {
        self.id = id
        self.username = username
        self.avatar = avatar
    }

    func getAvatar() -> UIImage {
        if avatar != nil {
            return avatar!
        } else {
            return UIImage(named: "default")!
        }
    }

}