//
//  Status.swift
//  BillSplitter
//
//  Created by gomeow on 5/9/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import Foundation

class Status {

    var id: String
    var data: [[String:AnyObject]]

    init(id: String, data: [[String:AnyObject]]) {
        self.id = id
        self.data = data
    }

    init?(json: String) {
        let data: NSData = json.dataUsingEncoding(NSUTF8StringEncoding)!
        do {
            let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            self.id = jsonObject["id"] as! String
            self.data = jsonObject["data"] as! [[String: AnyObject]]
        } catch {
            return nil
        }
    }

    func getAmountByRecipient(userId: String) -> Double? {
        for object in data {
            if (object["recipient"] as! String) == userId {
                return object["amount"] as? Double
            }
        }
        return nil
    }

    func toString() -> String? {
        let jsonObject: [String: AnyObject] = [
            "id": self.id,
            "data": self.data
        ]
        do {
            return String(try NSJSONSerialization.dataWithJSONObject(jsonObject, options: []))
        } catch {
            return nil
        }
    }

    
}