//
//  NotVerifiedDomainTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 19/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class NotVerifiedDomainTableViewCell: UITableViewCell, RegisterableCell {
    
    var didTapVerifyButton: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    @IBAction private func verifyButtonTapped() {
        didTapVerifyButton?()
    }
}

