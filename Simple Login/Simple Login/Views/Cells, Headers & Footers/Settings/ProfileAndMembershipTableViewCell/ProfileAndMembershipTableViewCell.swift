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
    @IBOutlet private weak var upgradeDowngradeLabel: UILabel!
    
    var didTapModifyLabel: (() -> Void)?
    var didTapUpgradeDowngradeLabel: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapModify = UITapGestureRecognizer(target: self, action: #selector(modifyLabelTapped))
        modifyLabel.isUserInteractionEnabled = true
        modifyLabel.addGestureRecognizer(tapModify)
        
        let tapUpgradeDowngrade = UITapGestureRecognizer(target: self, action: #selector(upgradeDowngradeLabelTapped))
        upgradeDowngradeLabel.isUserInteractionEnabled = true
        upgradeDowngradeLabel.addGestureRecognizer(tapUpgradeDowngrade)
    }
    
    @objc private func modifyLabelTapped() {
        didTapModifyLabel?()
    }
    
    @objc private func upgradeDowngradeLabelTapped() {
        didTapUpgradeDowngradeLabel?()
    }
}
