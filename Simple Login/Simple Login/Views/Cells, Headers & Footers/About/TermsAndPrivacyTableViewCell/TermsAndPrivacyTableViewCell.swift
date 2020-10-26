//
//  TermsAndPrivacyTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class TermsAndPrivacyTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var termsLabel: UILabel!
    @IBOutlet private weak var privacyLabel: UILabel!

    var didTapTermsLabel: (() -> Void)?
    var didTapPrivacyLabel: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        let tapTerms = UITapGestureRecognizer(target: self, action: #selector(termsLabelTapped))
        termsLabel.isUserInteractionEnabled = true
        termsLabel.addGestureRecognizer(tapTerms)

        let tapPrivacy = UITapGestureRecognizer(target: self, action: #selector(privacyLabelTapped))
        privacyLabel.isUserInteractionEnabled = true
        privacyLabel.addGestureRecognizer(tapPrivacy)
    }

    @objc
    private func termsLabelTapped() {
        didTapTermsLabel?()
    }

    @objc
    private func privacyLabelTapped() {
        didTapPrivacyLabel?()
    }
}
