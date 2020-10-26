//
//  ProfileAndMembershipTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class ProfileAndMembershipTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var avatarImageView: AvatarImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var modifyLabel: UILabel!
    @IBOutlet private weak var membershipLabel: UILabel!
    @IBOutlet private weak var upgradeLabel: UILabel!

    var didTapModifyLabel: (() -> Void)?
    var didTapUpgradeLabel: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

//        let tapModify = UITapGestureRecognizer(target: self, action: #selector(modifyLabelTapped))
//        modifyLabel.isUserInteractionEnabled = true
//        modifyLabel.addGestureRecognizer(tapModify)
        modifyLabel.isHidden = true

        let tapUpgrade = UITapGestureRecognizer(target: self, action: #selector(upgradeLabelTapped))
        upgradeLabel.isUserInteractionEnabled = true
        upgradeLabel.addGestureRecognizer(tapUpgrade)
    }

    @objc
    private func modifyLabelTapped() {
        didTapModifyLabel?()
    }

    @objc
    private func upgradeLabelTapped() {
        didTapUpgradeLabel?()
    }

    func bind(with userInfo: UserInfo) {
        usernameLabel.text = userInfo.name
        emailLabel.text = userInfo.email

        if userInfo.inTrial {
            membershipLabel.text = "Premium trial membership"
            membershipLabel.textColor = .systemBlue
            upgradeLabel.isHidden = false
        } else if userInfo.isPremium {
            membershipLabel.text = "Premium membership"
            membershipLabel.textColor = SLColor.premiumColor
            upgradeLabel.isHidden = true
        } else {
            membershipLabel.text = "Free membership"
            membershipLabel.textColor = SLColor.titleColor
            upgradeLabel.isHidden = false
        }
    }
}
