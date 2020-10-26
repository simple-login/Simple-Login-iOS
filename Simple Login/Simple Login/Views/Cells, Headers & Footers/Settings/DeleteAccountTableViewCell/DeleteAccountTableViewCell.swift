//
//  DeleteAccountTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class DeleteAccountTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var deleteLabel: UILabel!

    var didTapDeleteLabel: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        let tap = UITapGestureRecognizer(target: self, action: #selector(deleteLabelTapped))
        deleteLabel.isUserInteractionEnabled = true
        deleteLabel.addGestureRecognizer(tap)
    }

    @objc
    private func deleteLabelTapped() {
        didTapDeleteLabel?()
    }
}
