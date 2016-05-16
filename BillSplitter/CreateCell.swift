//
//  CreateCell.swift
//  BillSplitter
//
//  Created by gomeow on 5/6/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class CreateCell: UITableViewCell {

    @IBOutlet weak var addMember: UIButton!
    @IBOutlet weak var newTransactionButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!

    var delegate: GroupButtonBarDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        let newTransactionlayerL: CALayer = CALayer()
        newTransactionlayerL.frame = CGRectMake(-5.0, 0.0, 2.0, newTransactionButton.layer.frame.height)
        newTransactionlayerL.backgroundColor = UIColor.grayColor().CGColor
        newTransactionButton.layer.addSublayer(newTransactionlayerL)
        let newTransactionlayerR: CALayer = CALayer()
        newTransactionlayerR.frame = CGRectMake(newTransactionButton.layer.frame.width + 5.0, 0.0, 2.0, newTransactionButton.layer.frame.height)
        newTransactionlayerR.backgroundColor = UIColor.grayColor().CGColor
        newTransactionButton.layer.addSublayer(newTransactionlayerR)

        addMember.addTarget(self, action: #selector(CreateCell.add), forControlEvents: .TouchUpInside)
        newTransactionButton.addTarget(self, action: #selector(CreateCell.newTransaction), forControlEvents: .TouchUpInside)
        historyButton.addTarget(self, action: #selector(CreateCell.history), forControlEvents: .TouchUpInside)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func add() {
        delegate?.buttonPressed(0)
    }

    func newTransaction() {
        delegate?.buttonPressed(1)
    }

    func history() {
        delegate?.buttonPressed(2)
    }
}
