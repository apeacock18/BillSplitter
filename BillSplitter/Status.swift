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
        let data: Data = json.data(using: String.Encoding.utf8)!
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data as Data, options: []) as! [String: Any]
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
            "id": self.id as AnyObject,
            "data": self.data as AnyObject
        ]
        do {
            return String(describing: try JSONSerialization.data(withJSONObject: jsonObject, options: []))
        } catch {
            return nil
        }
    }

    
}
