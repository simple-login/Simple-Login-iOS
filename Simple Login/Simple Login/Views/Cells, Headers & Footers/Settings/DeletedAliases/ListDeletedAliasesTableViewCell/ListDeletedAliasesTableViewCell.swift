//
//  ListDeletedAliasesTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 26/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class ListDeletedAliasesTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var rootView: BorderedShadowedView!
    
    var didTapRootView: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(rootViewTapped))
        rootView.isUserInteractionEnabled = true
        rootView.addGestureRecognizer(tap)
    }
    
    @objc private func rootViewTapped() {
        didTapRootView?()
    }
}
