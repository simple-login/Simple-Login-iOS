//
//  AvatarImageView.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

class AvatarImageView: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpUI()
    }
    
    private func setUpUI() {
        layer.cornerRadius = bounds.width / 2
        layer.borderWidth = 2
        layer.borderColor = SLColor.tintColor.cgColor
        layer.backgroundColor = SLColor.tintColor.withAlphaComponent(0.5).cgColor
    }
}
