//
//  Transaction.swift
//  BillSplitter
//
//  Created by Davis Mariotti on 4/25/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import Foundation

class Transaction {

    var payee: String
    var split: [String:Int]
    var amount: Double
    var desc: String
    var date: String

    init(payee: String, amount: Double, split: [String:Int], desc: String, date: String)
    {
        self.payee = payee
        self.amount = amount
        self.split = split
        self.desc = desc
        self.date = date
    }

    init?(json: String) {

        let data: Data = json.data(using: String.Encoding.utf8)!
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data as Data, options: []) as! [String: Any?]
            self.payee = jsonObject["payee"] as! String
            self.split = jsonObject["split"] as! [String:Int]
            self.amount = jsonObject["amount"] as! Double
            self.desc = jsonObject["description"] as! String
            self.date = jsonObject["date"] as! String
        } catch {
            return nil
        }
    }

    func getShare(id: String) -> Double {
        if let splitPercentage = split[id] {
            return amount * Double(splitPercentage)
        } else {
            return 0.0
        }
    }

    func getDateInSeconds() -> Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: date)!.timeIntervalSince1970
    }


    func toString() -> String? {
        let jsonObject: [String: AnyObject] = [
            "payee": self.payee as AnyObject,
            "split": self.split as AnyObject,
            "amount": self.amount as AnyObject,
            "description": self.desc as AnyObject,
            "date": self.date as AnyObject
        ]
        do {
            return String(describing: try JSONSerialization.data(withJSONObject: jsonObject, options: []))
        } catch {
            return nil
        }
    }

    /*

     Example JSON:

     {"payee":"v4vh5hb6", "split": ["vbghnkl54": .33333333333, "5vgh45bc2": .33333333333, "45ghvb33f": .33333333333], amount: 20.00, description: "Electricity"}

     */
    
    
}
