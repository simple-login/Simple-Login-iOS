//
//  AliasActivityTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class AliasActivityTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var activityLabel: UILabel!
    @IBOutlet private weak var clockImageView: UIImageView!
    @IBOutlet private weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        activityLabel.textColor = SLColor.textColor
        
        clockImageView.tintColor = SLColor.titleColor
        timeLabel.textColor = SLColor.titleColor
    }
}