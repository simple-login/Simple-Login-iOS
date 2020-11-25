//
//  SenderFormatTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 25/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class SenderFormatTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var senderFormatContainerView: UIView!
    @IBOutlet private weak var senderFormatLabel: UILabel!

    var didTapSenderFormatButton: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        let tap = UITapGestureRecognizer(target: self, action: #selector(senderFormatContainerViewTapped))
        senderFormatContainerView.isUserInteractionEnabled = true
        senderFormatContainerView.addGestureRecognizer(tap)
        senderFormatContainerView.layer.cornerRadius = 2
    }

    @objc
    private func senderFormatContainerViewTapped() {
        didTapSenderFormatButton?()
    }

    func bind(userSettings: UserSettings) {
        senderFormatLabel.text = userSettings.senderFormat.description
    }
}
