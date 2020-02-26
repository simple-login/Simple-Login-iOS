//
//  DirectoryTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 26/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class DirectoryTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var clockImageView: UIImageView!
    @IBOutlet private weak var creationLabel: UILabel!
    
    var didTapDelete: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    @IBAction private func deleteButtonTapped() {
        didTapDelete?()
    }
    
    func bind(with directory: Directory) {
        nameLabel.text = directory.name
        countLabel.attributedText = directory.countAttributedString
        creationLabel.text = directory.creationTimestampString
    }
}
