//
//  LeftMenuOptionTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class LeftMenuOptionTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var optionTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        optionTitleLabel.textColor = .darkGray
    }
    
    func bind(with leftMenuOption: LeftMenuOption) {
        iconImageView.image = UIImage(named: leftMenuOption.iconName)
        optionTitleLabel.text = leftMenuOption.description
    }
}
