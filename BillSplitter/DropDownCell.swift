//
//  DropDownCell.swift
//  BillSplitter
//
//  Created by gomeow on 5/13/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class DropDownCell: UITableViewCell {

    @IBOutlet weak var nameField: UILabel!

    var id: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
