//
//  ContactTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Toaster

final class ContactTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var destinationEmailLabel: UILabel!
    @IBOutlet private weak var clockImageView: UIImageView!
    @IBOutlet private weak var creationDateLabel: UILabel!
    @IBOutlet private weak var sendStackView: UIStackView!
    @IBOutlet private weak var sendImageView: UIImageView!
    @IBOutlet private weak var lastSentLabel: UILabel!
    @IBOutlet private weak var createButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    
    var didTapWriteEmailButton: (() -> Void)?
    var didTapDeleteButton: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = UITableViewCell.SelectionStyle.none

        destinationEmailLabel.textColor = SLColor.textColor
        
        createButton.tintColor = SLColor.tintColor
        createButton.setTitleColor(SLColor.tintColor, for: .normal)
        
        deleteButton.tintColor = SLColor.negativeColor
        deleteButton.setTitleColor(SLColor.negativeColor, for: .normal)
        
        clockImageView.tintColor = SLColor.titleColor
        sendImageView.tintColor = SLColor.titleColor
        creationDateLabel.textColor = SLColor.titleColor
        lastSentLabel.textColor = SLColor.titleColor
    }
    
    func bind(with contact: Contact) {
        destinationEmailLabel.text = contact.email
        creationDateLabel.text = contact.creationTimestampString
        
        lastSentLabel.text = contact.lastEmailSentTimestampString
        sendStackView.isHidden = contact.lastEmailSentTimestampString == nil
    }
    
    @IBAction private func writeEmailButtonTapped() {
        didTapWriteEmailButton?()
    }
    
    @IBAction private func deleteButtonTapped() {
        didTapDeleteButton?()
    }
}
