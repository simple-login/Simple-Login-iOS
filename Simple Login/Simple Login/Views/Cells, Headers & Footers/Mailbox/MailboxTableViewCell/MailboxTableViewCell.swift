//
//  MailboxTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 28/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import UIKit

final class MailboxTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var defaultButton: UIButton!
    @IBOutlet private weak var clockImageView: UIImageView!
    @IBOutlet private weak var creationDateLabel: UILabel!
    @IBOutlet private weak var waveImageView: UIImageView!
    @IBOutlet private weak var numOfAliasLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = UITableViewCell.SelectionStyle.none

        emailLabel.textColor = SLColor.textColor
        defaultButton.layer.cornerRadius = 4.0
        clockImageView.tintColor = SLColor.titleColor
        waveImageView.tintColor = SLColor.titleColor
        creationDateLabel.textColor = SLColor.titleColor
        numOfAliasLabel.textColor = SLColor.titleColor
    }
    
    func bind(with mailbox: Mailbox) {
        emailLabel.text = mailbox.email
        defaultButton.isHidden = !mailbox.isDefault
        creationDateLabel.text = mailbox.creationString
        numOfAliasLabel.attributedText = mailbox.numOfAliasAttributedString
    }
}
