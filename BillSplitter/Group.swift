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

    private var name: String = ""

    private var members: Array<String> = []

    // TODO create a status object
    //private var status


    init(name: String, members: Array<String>) {
        self.name = name
        self.members = members
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