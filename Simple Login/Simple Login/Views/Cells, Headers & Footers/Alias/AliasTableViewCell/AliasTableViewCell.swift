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
    @IBOutlet private weak var rootView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var clockImageView: UIImageView!
    @IBOutlet private weak var creationLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var enabledSwitch: UISwitch!
    @IBOutlet private weak var copyButton: UIButton!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var rightArrowButton: UIButton!
    
    weak var alias: Alias?
    
    var didToggleStatus: ((_ enabled: Bool) -> Void)?
    var didTapSendButton: (() -> Void)?
    var didTapDeleteButton: (() -> Void)?
    var didTapRightArrowButton: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = UITableViewCell.SelectionStyle.none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        rootView.layer.cornerRadius = CORNER_RADIUS
        
        enabledSwitch.onTintColor = SLColor.tintColor
        
        copyButton.tintColor = SLColor.tintColor
        copyButton.setTitleColor(SLColor.tintColor, for: .normal)
        
        sendButton.tintColor = SLColor.tintColor
        sendButton.setTitleColor(SLColor.tintColor, for: .normal)
        
        nameLabel.textColor = SLColor.textColor
        
        clockImageView.tintColor = SLColor.titleColor
        creationLabel.textColor = SLColor.titleColor
        
        deleteButton.tintColor = SLColor.negativeColor
        deleteButton.setTitleColor(SLColor.negativeColor, for: .normal)
        
        rightArrowButton.tintColor = SLColor.titleColor
    }
    
    func bind(with alias: Alias) {
        self.alias = alias
        nameLabel.text = alias.name
        enabledSwitch.isOn = alias.isEnabled
        sendButton.isEnabled = alias.isEnabled
        copyButton.isEnabled = alias.isEnabled
        countLabel.attributedText = alias.countAttributedString
        
        if alias.isEnabled {
            rootView.backgroundColor = SLColor.frontBackgroundColor
        } else {
            rootView.backgroundColor = SLColor.inactiveFrontBackgroundColor
        }
    }
    
    @IBAction private func enabledSwitchValueChanged() {
        alias?.toggleIsEnabled()
        if let alias = alias {
            bind(with: alias)
        }
        
        didToggleStatus?(enabledSwitch.isOn)
    }
    
    @IBAction private func copyButtonTapped() {
        guard let alias = alias else { return }
        UIPasteboard.general.string = alias.name
        Toast.displayShortly(message: "Copied \(alias.name) to clipboard")
    }
    
    @IBAction private func sendButtonTapped() {
        didTapSendButton?()
    }
    
    @IBAction private func deleteButtonTapped() {
        didTapDeleteButton?()
    }
    
    @IBAction private func rightArrowButtonTapped() {
        didTapRightArrowButton?()
    }
}
