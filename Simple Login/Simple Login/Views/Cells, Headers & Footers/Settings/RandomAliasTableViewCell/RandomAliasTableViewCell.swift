//
//  RandomAliasTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 22/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class RandomAliasTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var randomModeContainerView: UIView!
    @IBOutlet private weak var randomModeLabel: UILabel!
    @IBOutlet private weak var defaultDomainContainerView: UIView!
    @IBOutlet private weak var defaultDomainLabel: UILabel!

    var didTapRandomModeButton: (() -> Void)?
    var didTapDefaultDomainButton: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        let randomModeTap = UITapGestureRecognizer(target: self, action: #selector(randomModeContainerViewTapped))
        randomModeContainerView.isUserInteractionEnabled = true
        randomModeContainerView.addGestureRecognizer(randomModeTap)
        randomModeContainerView.layer.cornerRadius = 2

        let defaultDomainTap = UITapGestureRecognizer(target: self,
                                                      action: #selector(defaultDomainContainerViewTapped))
        defaultDomainContainerView.isUserInteractionEnabled = true
        defaultDomainContainerView.addGestureRecognizer(defaultDomainTap)
        defaultDomainContainerView.layer.cornerRadius = 2
    }

    @objc
    private func randomModeContainerViewTapped() {
        didTapRandomModeButton?()
    }

    @objc
    private func defaultDomainContainerViewTapped() {
        didTapDefaultDomainButton?()
    }

    func bind(userSettings: UserSettings) {
        randomModeLabel.text = userSettings.randomMode.description
        defaultDomainLabel.text = userSettings.randomAliasDefaultDomain
    }
}
