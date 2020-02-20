//
//  UIViewController+Convenience.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 20/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

extension UIViewController {
    func alertError(_ error: SLError, closeActionHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Error occured", message: error.description, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default) { (_) in
            closeActionHandler?()
        }
        alert.addAction(closeAction)
        present(alert, animated: true, completion: nil)
    }
}
