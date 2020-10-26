//
//  MfaTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class MfaTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var enableDisableLabel: UILabel!

    var didTapEnableDisableLabel: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        let tap = UITapGestureRecognizer(target: self, action: #selector(enableDisableLabelTapped))
        enableDisableLabel.isUserInteractionEnabled = true
        enableDisableLabel.addGestureRecognizer(tap)
    }

    @objc
    private func enableDisableLabelTapped() {
        didTapEnableDisableLabel?()
    }
}
