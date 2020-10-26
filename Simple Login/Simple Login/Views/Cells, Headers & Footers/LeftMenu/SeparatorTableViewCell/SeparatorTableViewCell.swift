//
//  SeparatorTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class SeparatorTableViewCell: UITableViewCell, RegisterableCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = SLColor.separatorColor
    }
}
