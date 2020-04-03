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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = UITableViewCell.SelectionStyle.none

        destinationEmailLabel.textColor = SLColor.textColor
        
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
}
