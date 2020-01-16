//
//  HowAndFaqTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class HowAndFaqTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var rootView: UIView!
    @IBOutlet private weak var howLabel: UILabel!
    @IBOutlet private weak var faqLabel: UILabel!
    
    var didTapHowItWorksLabel: (() -> Void)?
    var didTapFaqLabel: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rootView.layer.cornerRadius = CORNER_RADIUS
        
        let tapHow = UITapGestureRecognizer(target: self, action: #selector(howItWorksLabelTapped))
        howLabel.isUserInteractionEnabled = true
        howLabel.addGestureRecognizer(tapHow)
        
        let tapFaq = UITapGestureRecognizer(target: self, action: #selector(faqLabelTapped))
        faqLabel.isUserInteractionEnabled = true
        faqLabel.addGestureRecognizer(tapFaq)
    }
    
    @objc private func howItWorksLabelTapped() {
        didTapHowItWorksLabel?()
    }
    
    @objc private func faqLabelTapped() {
        didTapFaqLabel?()
    }
}
