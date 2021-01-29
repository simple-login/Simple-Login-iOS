//
//  TeamAndBlogTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 29/01/2021.
//  Copyright © 2021 SimpleLogin. All rights reserved.
//

import UIKit

final class TeamAndBlogTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var teamLabel: UILabel!
    @IBOutlet private weak var blogLabel: UILabel!

    var didTapTeamLabel: (() -> Void)?
    var didTapBlogLabel: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        let tapTeam = UITapGestureRecognizer(target: self, action: #selector(teamLabelTapped))
        teamLabel.isUserInteractionEnabled = true
        teamLabel.addGestureRecognizer(tapTeam)

        let tapBlog = UITapGestureRecognizer(target: self, action: #selector(blogLabelTapped))
        blogLabel.isUserInteractionEnabled = true
        blogLabel.addGestureRecognizer(tapBlog)
    }

    @objc
    private func teamLabelTapped() {
        didTapTeamLabel?()
    }

    @objc
    private func blogLabelTapped() {
        didTapBlogLabel?()
    }
}
