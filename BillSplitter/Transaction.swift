//
//  Transaction.swift
//  p2
//
//  Created by Andrew Peacock on 3/11/16.
//  Copyright © 2016 Andrew Peacock. All rights reserved.
//

import UIKit

class Transaction {
    
    var name: String
    var to: String
    var photo: UIImage
    var amount: Double
    
    init(name: String, photo: UIImage, amount: Double)
    {
        self.name = name
        self.photo = photo
        self.amount = amount
        self.to = ""
    }
    
    func toString() {
        let jsonObject: [String: AnyObject] = [
        "name": self.name,
        "to": self.to,
        "amount": self.amount
        ]
        let valid = NSJSONSerialization.isValidJSONObject(jsonObject)
    }
    
}
