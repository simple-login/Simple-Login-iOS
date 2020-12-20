//
//  BiometricAuthTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/12/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class BiometricAuthTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var activationSwitch: UISwitch!

    var didSwitch: ((_ isOn: Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func bind(text: String) {
        titleLabel.text = text
        activationSwitch.isOn = UserDefaults.activeBiometricAuth()
    }

    func setSwitch(isOn: Bool) {
        activationSwitch.isOn = isOn
    }

    @IBAction private func switchValueChanged(_ sender: UISwitch) {
        didSwitch?(sender.isOn)
    }
}
