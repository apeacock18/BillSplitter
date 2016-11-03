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
        newTransactionlayerL.frame = CGRect(x: -7.0, y: 0.0, width: 2.0, height: newTransactionButton.layer.frame.height)
        newTransactionlayerL.backgroundColor = UIColor.gray.cgColor
        newTransactionButton.layer.addSublayer(newTransactionlayerL)
        let newTransactionlayerR: CALayer = CALayer()
        newTransactionlayerR.frame = CGRect(x: newTransactionButton.layer.frame.width + 7.0, y: 0.0, width: 2.0, height: newTransactionButton.layer.frame.height)
        newTransactionlayerR.backgroundColor = UIColor.gray.cgColor
        newTransactionButton.layer.addSublayer(newTransactionlayerR)

        addMember.addTarget(self, action: #selector(CreateCell.add), for: .touchUpInside)
        newTransactionButton.addTarget(self, action: #selector(CreateCell.newTransaction), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(CreateCell.history), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func add() {
        delegate?.buttonPressed(index: 0)
    }

    func newTransaction() {
        delegate?.buttonPressed(index: 1)
    }

    func history() {
        delegate?.buttonPressed(index: 2)
    }
}
