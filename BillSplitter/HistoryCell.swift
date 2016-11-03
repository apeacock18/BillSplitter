//
//  HistoryCell.swift
//  BillSplitter
//
//  Created by gomeow on 5/16/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var payee: UILabel!
    @IBOutlet weak var split: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var share: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var desc: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        payee.adjustsFontSizeToFitWidth = true
        total.adjustsFontSizeToFitWidth = true
        share.adjustsFontSizeToFitWidth = true
        date.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
