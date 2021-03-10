//
//  CustomDomainTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 18/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class CustomDomainTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var rootView: BorderedShadowedView!
    @IBOutlet private weak var domainNameLabel: UILabel!
    @IBOutlet private weak var clockImageView: UIImageView!
    @IBOutlet private weak var creationDateLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var rightArrowButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        domainNameLabel.textColor = SLColor.textColor
        clockImageView.tintColor = SLColor.titleColor
        creationDateLabel.textColor = SLColor.titleColor
        rightArrowButton.tintColor = SLColor.titleColor
    }

    func bind(with customDomain: CustomDomain) {
        domainNameLabel.text = customDomain.domainName + (customDomain.isVerified ? " ✅" : " 🚫")
        creationDateLabel.text = customDomain.creationTimestampString
        countLabel.attributedText = customDomain.countAttributedString
    }
}
