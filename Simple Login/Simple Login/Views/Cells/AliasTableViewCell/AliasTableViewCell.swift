//
//  AliasTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class AliasTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var rootView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var creationLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var enabledSwitch: UISwitch!
    @IBOutlet private weak var sendButton: UIButton!
    
    weak var alias: Alias?
    
    var didTapSendButton: (() -> Void)?
    var didTapDeleteButton: (() -> Void)?
    var didTapRightArrowButton: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = UITableViewCell.SelectionStyle.none
        rootView.layer.cornerRadius = 8
    }
    
    func bind(with alias: Alias) {
        self.alias = alias
        nameLabel.text = alias.name
        enabledSwitch.isOn = alias.isEnabled
        sendButton.isEnabled = alias.isEnabled
        
        if alias.isEnabled {
            rootView.backgroundColor = .white
        } else {
            rootView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        }
    }
    
    @IBAction private func enabledSwitchValueChanged() {
        alias?.toggleIsEnabled()
        if let alias = alias {
            bind(with: alias)
        }
    }
    
    @IBAction private func sendButtonTapped() {
    
    }
    
    @IBAction private func deleteButtonTapped() {
        
    }
    
    @IBAction private func rightArrowButtonTapped() {
        
    }
}
