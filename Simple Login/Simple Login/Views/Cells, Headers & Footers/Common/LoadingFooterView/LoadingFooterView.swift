//
//  LoadingFooterView.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 06/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class LoadingFooterView: UITableViewHeaderFooterView {
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func animate() {
        activityIndicator.startAnimating()
    }
}
