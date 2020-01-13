//
//  ReverseAliasTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Toaster

final class ReverseAliasTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var rootView: UIView!
    @IBOutlet private weak var destinationEmailLabel: UILabel!
    @IBOutlet private weak var creationDateLabel: UILabel!
    
    var didTapWriteEmailButton: (() -> Void)?
    var didTapDeleteButton: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        selectionStyle = UITableViewCell.SelectionStyle.none
        rootView.layer.cornerRadius = 8
    }
    
    func bind(with reverseAlias: ReverseAlias) {
        destinationEmailLabel.text = reverseAlias.destinationEmail
    }
    
    @IBAction private func writeEmailButtonTapped() {
        didTapWriteEmailButton?()
    }
    
    @IBAction private func deleteButtonTapped() {
        didTapDeleteButton?()
    }
}
