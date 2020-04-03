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
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var clockImageView: UIImageView!
    @IBOutlet private weak var creationLabel: UILabel!
    @IBOutlet private weak var waveImageView: UIImageView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var noteLabel: UILabel!
    @IBOutlet private weak var enabledSwitch: UISwitch!
    @IBOutlet private weak var copyButton: UIButton!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var rightArrowButton: UIButton!
    
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
        
        nameLabel.textColor = SLColor.textColor
        noteLabel.textColor = SLColor.textColor
        
        clockImageView.tintColor = SLColor.titleColor
        creationLabel.textColor = SLColor.titleColor
        
        waveImageView.tintColor = SLColor.titleColor
        
        rightArrowButton.tintColor = SLColor.titleColor
    }
    
    func bind(with alias: Alias) {
        self.alias = alias
        nameLabel.text = alias.email
        
        if let note = alias.note {
            noteLabel.text = note
            noteLabel.isHidden = false
        } else {
            noteLabel.isHidden = true
        }
        
        enabledSwitch.isOn = alias.enabled
        countLabel.attributedText = alias.countAttributedString
        creationLabel.text = alias.creationString
        
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
