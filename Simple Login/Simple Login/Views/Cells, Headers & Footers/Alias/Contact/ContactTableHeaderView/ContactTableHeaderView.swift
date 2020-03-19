//
//  ContactTableHeaderView.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 19/03/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import MarqueeLabel

final class ContactTableHeaderView: UITableViewHeaderFooterView {
    @IBOutlet private weak var rootView: UIView!
    @IBOutlet private weak var emailLabel: MarqueeLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rootView.backgroundColor = .lightGray
        emailLabel.type = .leftRight
    }
    
    func bind(with email: String) {
        emailLabel.text = email
        emailLabel.triggerScrollStart()
    }
}
