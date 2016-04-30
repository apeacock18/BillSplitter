//
//  Transaction.swift
//  BillSplitter
//
//  Created by Davis Mariotti on 4/25/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class Transaction {

    var payee: String
    var from: Array<String>
    var amount: Double
    var reason: String

    init(name: String, amount: Double, from: Array<String>, reason: String)
    {
        self.payee = name
        self.amount = amount
        self.from = from
        self.reason = reason
    }

    init?(json: String) {

        let data: NSData = json.dataUsingEncoding(NSUTF8StringEncoding)!
        do {
            let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            self.payee = jsonObject["payee"] as! String
            self.from = jsonObject["from"] as! Array<String>
            self.amount = jsonObject["amount"] as! Double
            self.reason = jsonObject["reason"] as! String
        } catch {
            return nil
        }
    }

    func toString() -> String? {
        let jsonObject: [String: AnyObject] = [
            "payee": self.payee,
            "from": self.from,
            "amount": self.amount,
            "reason": self.reason
        ]
        do {
            return String(try NSJSONSerialization.dataWithJSONObject(jsonObject, options: []))
        } catch {
            return nil
        }
    }

    /*

     Example JSON:

     {"payee":"v4vh5hb6", "from": ["vbghnkl54", "5vgh45bc2", "45ghvb33f"], amount: 20.0, reason: "Electricity"}

     */
    
    
}