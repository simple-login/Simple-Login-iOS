//
//  DomainCatchAllTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 26/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class DomainCatchAllTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var catchAllSwitch: UISwitch!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    var didSwitch: ((_ isOn: Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    @IBAction private func switched() {
        didSwitch?(catchAllSwitch.isOn)
    }
    
    func bind(with customDomain: CustomDomain) {
        descriptionLabel.attributedText = customDomain.catchAllDescriptionString
    }
}
