//
//  AliasActivityTableHeaderView.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class AliasActivityTableHeaderView: UITableViewHeaderFooterView {
    @IBOutlet private weak var creationDateLabel: UILabel!
    @IBOutlet private weak var mailboxesLabel: UILabel!
    @IBOutlet private weak var editMailboxesButton: UIButton!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var editNameButton: UIButton!
    @IBOutlet private weak var noteLabel: UILabel!
    @IBOutlet private weak var editNoteButton: UIButton!
    @IBOutlet private weak var handledCountLabel: UILabel!
    @IBOutlet private weak var forwardedCountLabel: UILabel!
    @IBOutlet private weak var repliedCountLabel: UILabel!
    @IBOutlet private weak var blockedCountLabel: UILabel!
    @IBOutlet private weak var blockedRootView: UIView!

    @IBOutlet private var rootViews: [UIView]!
    @IBOutlet private var countLabels: [UILabel]!
    @IBOutlet private var titleLabels: [UILabel]!
    @IBOutlet private var countImageViews: [UIImageView]!

    var didTapEditNoteButton: (() -> Void)?
    var didTapEditMailboxesButton: (() -> Void)?
    var didTapEditNameButton: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        rootViews.forEach {
            $0.backgroundColor = SLColor.tintColor.withAlphaComponent(0.7)
            $0.layer.cornerRadius = 4
        }
        blockedRootView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)

        countImageViews.forEach {
            $0.backgroundColor = .clear
            $0.tintColor = UIColor.white.withAlphaComponent(0.2)
        }

        countLabels.forEach {
            $0.textColor = UIColor.white
            $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        }

        titleLabels.forEach { $0.textColor = UIColor.white.withAlphaComponent(0.7) }
    }

    func bind(with alias: Alias) {
        creationDateLabel.text = alias.creationTimestampString
        mailboxesLabel.attributedText = alias.mailboxes.toAttributedString(fontSize: 14)

        if let name = alias.name {
            nameLabel.text = name
            nameLabel.font = UIFont.systemFont(ofSize: 14)
            editNameButton.setTitle("Edit name", for: .normal)
        } else {
            nameLabel.text = "<No display name>"
            nameLabel.font = UIFont.italicSystemFont(ofSize: 14)
            editNameButton.setTitle("Add name", for: .normal)
        }

        if let note = alias.note {
            noteLabel.text = note
            noteLabel.font = UIFont.systemFont(ofSize: 14)
            editNoteButton.setTitle("Edit note", for: .normal)
        } else {
            noteLabel.text = "<No note>"
            noteLabel.font = UIFont.italicSystemFont(ofSize: 14)
            editNoteButton.setTitle("Add note", for: .normal)
        }

        handledCountLabel.text = "\(alias.replyCount + alias.forwardCount + alias.blockCount)"
        repliedCountLabel.text = "\(alias.replyCount)"
        forwardedCountLabel.text = "\(alias.forwardCount)"
        blockedCountLabel.text = "\(alias.blockCount)"
    }

    @IBAction private func editNoteButtonTapped() {
        didTapEditNoteButton?()
    }

    @IBAction private func editMailboxesButtonTapped() {
        didTapEditMailboxesButton?()
    }

    @IBAction private func editNameButtonTapped() {
        didTapEditNameButton?()
    }
}
