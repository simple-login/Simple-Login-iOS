//
//  PricingAndBlogTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class PricingAndBlogTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var rootView: UIView!
    @IBOutlet private weak var pricingLabel: UILabel!
    @IBOutlet private weak var blogLabel: UILabel!
    
    var didTapPricingLabel: (() -> Void)?
    var didTapBlogLabel: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rootView.layer.cornerRadius = CORNER_RADIUS
        
        let tapPricing = UITapGestureRecognizer(target: self, action: #selector(pricingLabelTapped))
        pricingLabel.isUserInteractionEnabled = true
        pricingLabel.addGestureRecognizer(tapPricing)
        
        let tapBlog = UITapGestureRecognizer(target: self, action: #selector(blogLabelTapped))
        blogLabel.isUserInteractionEnabled = true
        blogLabel.addGestureRecognizer(tapBlog)
    }
    
    @objc private func pricingLabelTapped() {
        didTapPricingLabel?()
    }
    
    @objc private func blogLabelTapped() {
        didTapBlogLabel?()
    }
}
