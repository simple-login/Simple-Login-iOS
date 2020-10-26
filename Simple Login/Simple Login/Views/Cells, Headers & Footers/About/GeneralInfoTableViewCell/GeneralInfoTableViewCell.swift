//
//  GeneralInfoTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class GeneralInfoTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        let versionString: String
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionString = "SimpleLogin v\(version)"
        } else {
            versionString = "SimpleLogin"
        }
        versionLabel.text = versionString
    }
}
