//
//  DeleteDomainTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 26/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class DeleteDomainTableViewCell: UITableViewCell, RegisterableCell {
    var didTapDeleteButton: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    @IBAction private func deleteButtonTapped() {
        didTapDeleteButton?()
    }
}
