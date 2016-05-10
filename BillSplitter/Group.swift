//
//  Group.swift
//  BillSplitter
//
//  Created by gomeow on 5/2/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import Foundation

class Group {

    private var id: String
    private var name: String
    private var members: Array<String>
    private var statuses: [Status]

    // TODO create a status object
    //private var status


    init(id: String, name: String, members: Array<String>) {
        self.id = id
        self.name = name
        self.members = members
        self.statuses = []
    }

    init(id: String, name: String, members: Array<String>, statuses: [Status]) {
        self.id = id
        self.name = name
        self.members = members
        self.statuses = statuses
    }

    func getID() -> String {
        return id
    }

    func getName() -> String {
        return name
    }

    func getMembers() -> Array<String> {
        return members
    }

    func addMember(userId: String) {
        members.append(userId)
    }

    func count() -> Int {
        return members.count
    }

    func getStatusById(userId: String) -> Status? {
        for status in statuses {
            if status.id == userId {
                return status
            }
        }
        return nil
    }

}