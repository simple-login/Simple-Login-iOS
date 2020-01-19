//
//  DomainInfoTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 19/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class DomainInfoTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var rootView: BorderedShadowedView!
    @IBOutlet private weak var domainNameLabel: UILabel!
    @IBOutlet private weak var clockImageView: UIImageView!
    @IBOutlet private weak var creationLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = UITableViewCell.SelectionStyle.none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        domainNameLabel.textColor = SLColor.textColor
        
        clockImageView.tintColor = SLColor.titleColor
        creationLabel.textColor = SLColor.titleColor
    }
    
    func bind(with customDomain: CustomDomain) {
        domainNameLabel.text = customDomain.name + (customDomain.isVerified ? "✅" : "🚫")
        countLabel.attributedText = customDomain.countAttributedString
    }
}
