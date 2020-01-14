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
    @IBOutlet private weak var mailImageView: UIImageView!
    @IBOutlet private weak var arrowLabel: UILabel!
    @IBOutlet private weak var destinationEmailLabel: UILabel!
    @IBOutlet private weak var clockImageView: UIImageView!
    @IBOutlet private weak var creationDateLabel: UILabel!
    @IBOutlet private weak var createButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    
    var didTapWriteEmailButton: (() -> Void)?
    var didTapDeleteButton: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = UITableViewCell.SelectionStyle.none
        
        rootView.backgroundColor = SLColor.frontBackgroundColor
        rootView.layer.cornerRadius = 8
        
        mailImageView.tintColor = SLColor.textColor
        arrowLabel.textColor = SLColor.textColor
        destinationEmailLabel.textColor = SLColor.textColor
        
        createButton.tintColor = SLColor.tintColor
        createButton.setTitleColor(SLColor.tintColor, for: .normal)
        
        deleteButton.tintColor = SLColor.negativeColor
        deleteButton.setTitleColor(SLColor.negativeColor, for: .normal)
        
        clockImageView.tintColor = SLColor.titleColor
        creationDateLabel.textColor = SLColor.titleColor
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
