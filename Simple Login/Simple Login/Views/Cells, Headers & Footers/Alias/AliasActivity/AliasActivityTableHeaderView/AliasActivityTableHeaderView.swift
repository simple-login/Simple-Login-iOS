//
//  AliasActivityTableHeaderView.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class AliasActivityTableHeaderView: UITableViewHeaderFooterView {
    @IBOutlet private weak var handledCountLabel: UILabel!
    @IBOutlet private weak var forwardedCountLabel: UILabel!
    @IBOutlet private weak var repliedCountLabel: UILabel!
    @IBOutlet private weak var blockedCountLabel: UILabel!
    @IBOutlet private weak var blockedRootView: UIView!
    
    @IBOutlet private var rootViews: [UIView]!
    @IBOutlet private var countLabels: [UILabel]!
    @IBOutlet private var titleLabels: [UILabel]!
    @IBOutlet private var imageViews: [UIImageView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = SLColor.backBackgroundColor
        
        rootViews.forEach({
            $0.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
            $0.layer.cornerRadius = 4
        })
        blockedRootView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
        
        imageViews.forEach({
            $0.backgroundColor = .clear
            $0.tintColor = UIColor.white.withAlphaComponent(0.2)
        })
        
        countLabels.forEach({
            $0.textColor = UIColor.white
            $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        })
        
        titleLabels.forEach({$0.textColor = UIColor.white.withAlphaComponent(0.7)})
    }
}
