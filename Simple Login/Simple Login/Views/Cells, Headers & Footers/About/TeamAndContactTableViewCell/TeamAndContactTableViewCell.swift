//
//  TeamAndContactTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class TeamAndContactTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var teamLabel: UILabel!
    @IBOutlet private weak var contactLabel: UILabel!

    var didTapTeamLabel: (() -> Void)?
    var didTapContactLabel: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        let tapTeam = UITapGestureRecognizer(target: self, action: #selector(teamLabelTapped))
        teamLabel.isUserInteractionEnabled = true
        teamLabel.addGestureRecognizer(tapTeam)

        let tapContact = UITapGestureRecognizer(target: self, action: #selector(contactLabelTapped))
        contactLabel.isUserInteractionEnabled = true
        contactLabel.addGestureRecognizer(tapContact)
    }

    @objc
    private func teamLabelTapped() {
        didTapTeamLabel?()
    }

    @objc
    private func contactLabelTapped() {
        didTapContactLabel?()
    }
}
