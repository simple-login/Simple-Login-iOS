//
//  WhatAndFaqTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 04/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class WhatAndFaqTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var whatLabel: UILabel!
    @IBOutlet private weak var faqLabel: UILabel!
    
    var didTapWhatLabel: (() -> Void)?
    var didTapFaqLabel: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapWhat = UITapGestureRecognizer(target: self, action: #selector(whatLabelTapped))
        whatLabel.isUserInteractionEnabled = true
        whatLabel.addGestureRecognizer(tapWhat)
        
        let tapFaq = UITapGestureRecognizer(target: self, action: #selector(faqLabelTapped))
        faqLabel.isUserInteractionEnabled = true
        faqLabel.addGestureRecognizer(tapFaq)
    }
    
    @objc private func whatLabelTapped() {
        didTapWhatLabel?()
    }
    
    @objc private func faqLabelTapped() {
        didTapFaqLabel?()
    }
}
