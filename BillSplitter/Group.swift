//
//  Group.swift
//  BillSplitter
//
//  Created by gomeow on 5/2/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import Foundation
import UIKit

class Group {

    private var id: String = ""
    private var name: String = ""
    private var members: Array<String> = []

    // TODO create a status object
    //private var status


    init(id: String, name: String, members: Array<String>) {
        self.id = id
        self.name = name
        self.members = members
    }

    func getID() -> String{
        return id
    }

    func getName() -> String {
        return name
    }

    func getMembers() -> Array<String> {
        return members
    }

    func count() -> Int {
        return members.count
    }

}