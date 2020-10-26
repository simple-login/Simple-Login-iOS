//
//  HelpAndRoadmapTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 04/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class HelpAndRoadmapTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var helpLabel: UILabel!
    @IBOutlet private weak var roadmapLabel: UILabel!

    var didTapHelpLabel: (() -> Void)?
    var didTapRoadmapLabel: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        let tapHelp = UITapGestureRecognizer(target: self, action: #selector(helpLabelTapped))
        helpLabel.isUserInteractionEnabled = true
        helpLabel.addGestureRecognizer(tapHelp)

        let tapRoadmap = UITapGestureRecognizer(target: self, action: #selector(roadmapLabelTapped))
        roadmapLabel.isUserInteractionEnabled = true
        roadmapLabel.addGestureRecognizer(tapRoadmap)
    }

    @objc
    private func helpLabelTapped() {
        didTapHelpLabel?()
    }

    @objc
    private func roadmapLabelTapped() {
        didTapRoadmapLabel?()
    }
}
