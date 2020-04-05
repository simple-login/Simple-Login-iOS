//
//  WhatTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class WhatTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var whatTitleLabel: UILabel!
    @IBOutlet private weak var whatImageView: UIImageView!
    @IBOutlet private weak var whatDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func bind(with what: What) {
        whatTitleLabel.text = what.title
        whatImageView.image = UIImage(named: what.imageName)
        whatDescriptionLabel.text = what.description
    }
}
