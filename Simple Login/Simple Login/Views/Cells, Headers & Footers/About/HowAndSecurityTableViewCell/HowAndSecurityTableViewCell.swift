//
//  HowAndSecurityTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class HowAndSecurityTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var howLabel: UILabel!
    @IBOutlet private weak var securityLabel: UILabel!
    
    var didTapHowItWorksLabel: (() -> Void)?
    var didTapSecurityLabel: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapHow = UITapGestureRecognizer(target: self, action: #selector(howItWorksLabelTapped))
        howLabel.isUserInteractionEnabled = true
        howLabel.addGestureRecognizer(tapHow)
        
        let tapSecurity = UITapGestureRecognizer(target: self, action: #selector(securityLabelTapped))
        securityLabel.isUserInteractionEnabled = true
        securityLabel.addGestureRecognizer(tapSecurity)
    }
    
    @objc private func howItWorksLabelTapped() {
        didTapHowItWorksLabel?()
    }
    
    @objc private func securityLabelTapped() {
        didTapSecurityLabel?()
    }
}
