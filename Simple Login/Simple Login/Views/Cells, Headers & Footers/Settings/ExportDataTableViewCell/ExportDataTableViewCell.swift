//
//  ExportDataTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class ExportDataTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var rootView: BorderedShadowedView!

    var didTapRootView: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        let tap = UITapGestureRecognizer(target: self, action: #selector(rootViewTapped))
        rootView.isUserInteractionEnabled = true
        rootView.addGestureRecognizer(tap)
    }

    @objc
    private func rootViewTapped() {
        didTapRootView?()
    }
}
