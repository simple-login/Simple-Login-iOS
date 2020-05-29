//
//  AliasTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Toaster

final class AliasTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var rootView: BorderedShadowedView!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var creationLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var mailboxesLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var noteLabel: UILabel!
    @IBOutlet private weak var enabledSwitch: UISwitch!
    @IBOutlet private weak var copyButton: UIButton!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var rightArrowButton: UIButton!
    
    @IBOutlet private weak var activityImageView: UIImageView!
    @IBOutlet private weak var nameStackView: UIStackView!
    
    @IBOutlet private var iconImageViews: [UIImageView]!
    
    weak var alias: Alias?
    
    var didToggleStatus: ((_ enabled: Bool) -> Void)?
    var didTapCopyButton: (() -> Void)?
    var didTapSendButton: (() -> Void)?
    var didTapRightArrowButton: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = UITableViewCell.SelectionStyle.none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        enabledSwitch.onTintColor = SLColor.tintColor
        
        copyButton.tintColor = SLColor.tintColor
        copyButton.setTitleColor(SLColor.tintColor, for: .normal)
        
        sendButton.tintColor = SLColor.tintColor
        sendButton.setTitleColor(SLColor.tintColor, for: .normal)
        
        emailLabel.textColor = SLColor.textColor
        noteLabel.textColor = SLColor.textColor
        
        creationLabel.textColor = SLColor.titleColor
        mailboxesLabel.textColor = SLColor.titleColor
        nameLabel.textColor = SLColor.titleColor
        
        rightArrowButton.tintColor = SLColor.titleColor
        
        iconImageViews.forEach({ $0.tintColor = SLColor.titleColor })
    }
    
    func bind(with alias: Alias) {
        self.alias = alias
        emailLabel.text = alias.email
        mailboxesLabel.attributedText = alias.mailboxesAttributedString
        
        nameStackView.isHidden = alias.name == nil
        nameLabel.text = alias.name
        
        noteLabel.isHidden = alias.note == nil
        noteLabel.text = alias.note
        
        enabledSwitch.isOn = alias.enabled
        countLabel.attributedText = alias.countAttributedString
        
        if let latestActivity = alias.latestActivity, let latestActivityString = alias.latestActivityString {
            switch latestActivity.action {
            case .block, .bounced: activityImageView.image = UIImage(named: "ClockIcon")
            case .forward: activityImageView.image = UIImage(named: "PaperPlaneIcon")
            case .reply: activityImageView.image = UIImage(named: "ReplyIcon")
            }
            creationLabel.text = latestActivityString
        } else {
            activityImageView.image = UIImage(named: "ClockIcon")
            creationLabel.text = alias.creationString
        }
        
        if alias.enabled {
            rootView.backgroundColor = SLColor.frontBackgroundColor
        } else {
            rootView.backgroundColor = SLColor.inactiveFrontBackgroundColor
        }
    }
    
    @IBAction private func enabledSwitchValueChanged() {
        didToggleStatus?(enabledSwitch.isOn)
    }
    
    @IBAction private func copyButtonTapped() {
        didTapCopyButton?()
    }
    
    @IBAction private func sendButtonTapped() {
        didTapSendButton?()
    }
    
    @IBAction private func rightArrowButtonTapped() {
        didTapRightArrowButton?()
    }
}
