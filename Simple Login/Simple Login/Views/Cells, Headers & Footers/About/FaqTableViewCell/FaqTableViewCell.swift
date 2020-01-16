//
//  FaqTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class FaqTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var faqTitleLabel: UILabel!
    @IBOutlet private weak var faqDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func bind(with faq: Faq) {
        faqTitleLabel.text = faq.title
        faqDescriptionLabel.text = faq.description
    }
}
