//
//  BorderedShadowedView.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

class BorderedShadowedView: UIView {
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
        layer.cornerRadius = CORNER_RADIUS
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.borderWidth = 0.5
        layer.borderColor = SLColor.borderColor.cgColor
        layer.shadowColor = SLColor.borderColor.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 1.0
    }
}
