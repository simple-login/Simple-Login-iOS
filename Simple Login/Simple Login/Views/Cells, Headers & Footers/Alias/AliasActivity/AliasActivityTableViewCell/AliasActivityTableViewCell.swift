//
//  AliasActivityTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class AliasActivityTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var contactLabel: UILabel!
    @IBOutlet private weak var clockImageView: UIImageView!
    @IBOutlet private weak var actionImageView: UIImageView!
    @IBOutlet private weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        contactLabel.textColor = SLColor.textColor

        clockImageView.tintColor = SLColor.titleColor
        timeLabel.textColor = SLColor.titleColor
    }

    func bind(with aliasActivity: AliasActivity) {
        timeLabel.text = aliasActivity.timestampString

        switch aliasActivity.action {
        case .forward:
            contactLabel.text = aliasActivity.from
            actionImageView.image = UIImage(named: "PaperPlaneIcon")
            actionImageView.tintColor = SLColor.tintColor

        case .reply:
            contactLabel.text = aliasActivity.to
            actionImageView.image = UIImage(named: "ReplyIcon")
            actionImageView.tintColor = SLColor.tintColor

        case .block:
            contactLabel.text = aliasActivity.from
            actionImageView.image = UIImage(named: "BlockIcon")
            actionImageView.tintColor = SLColor.negativeColor

        case .bounced:
            contactLabel.text = aliasActivity.from
            actionImageView.image = UIImage(named: "BlockIcon")
            actionImageView.tintColor = SLColor.negativeColor
        }
    }
}
