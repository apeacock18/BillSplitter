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
    var photo: UIImage
    var amount: Double
    
    init(name: String, photo: UIImage, amount: Double)
    {
        self.name = name
        self.photo = photo
        self.amount = amount
    }
    
}
