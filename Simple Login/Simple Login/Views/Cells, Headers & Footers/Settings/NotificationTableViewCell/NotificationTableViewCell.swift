//
//  NotificationTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class NotificationTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var notificationSwift: UISwitch!

    var didSwitch: ((_ isOn: Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    @IBAction private func switchValueChanged(_ sender: UISwitch) {
        didSwitch?(sender.isOn)
    }

    func bind(userSettings: UserSettings) {
        notificationSwift.isOn = userSettings.notification
    }
}
