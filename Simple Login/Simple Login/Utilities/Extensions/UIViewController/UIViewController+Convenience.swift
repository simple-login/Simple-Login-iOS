//
//  UIViewController+Convenience.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 04/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import MBProgressHUD
import MessageUI
import Toaster
import UIKit

extension UIViewController {
    func presentReverseAliasAlert(from: String,
                                  to: String,
                                  reverseAlias: String,
                                  reverseAliasAddress: String) {
        let style: UIAlertController.Style =
            UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet

        let alert = UIAlertController(title: "Compose and send email",
                                      message: "From: \"\(from)\"\nTo: \"\(to)\"",
                                      preferredStyle: style)

        let copyWithDisplayNameAction =
            UIAlertAction(title: "Copy reverse-alias (w/ display name)",
                          style: .default) { [unowned self] _ in
                UIPasteboard.general.string = reverseAlias
                MBProgressHUD.showCheckmarkHud(in: self.view, text: "Copied\n\(reverseAlias)")
            }
        alert.addAction(copyWithDisplayNameAction)

        let copyWithoutDisplayNameAction =
            UIAlertAction(title: "Copy reverse-alias (w/o display name)",
                          style: .default) { [unowned self] _ in
                UIPasteboard.general.string = reverseAliasAddress
                MBProgressHUD.showCheckmarkHud(in: self.view, text: "Copied\n\(reverseAliasAddress)")
            }
        alert.addAction(copyWithoutDisplayNameAction)

        let openEmaiAction = UIAlertAction(title: "Begin composing with default email",
                                           style: .default) { _ in
            if let mailToUrl = URL(string: "mailto:\(reverseAliasAddress)") {
                UIApplication.shared.open(mailToUrl)
            }
        }
        alert.addAction(openEmaiAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}
