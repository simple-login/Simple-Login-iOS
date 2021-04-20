//
//  UIViewController+Convenience.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 04/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import MessageUI
import Toaster
import UIKit

extension UIViewController {
    func presentReverseAliasAlert(from: String,
                                  to: String,
                                  reverseAlias: String,
                                  reverseAliasAddress: String,
                                  mailComposerVCDelegate: MFMailComposeViewControllerDelegate) {
        let style: UIAlertController.Style =
            UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet

        let alert = UIAlertController(title: "Compose and send email",
                                      message: "From: \"\(from)\"\nTo: \"\(to)\"",
                                      preferredStyle: style)

        let copyWithDisplayNameAction =
            UIAlertAction(title: "Copy reverse-alias (w/ display name)",
                          style: .default) { _ in
                UIPasteboard.general.string = reverseAlias
                Toast.displayShortly(message: "Copied \(reverseAlias)")
            }
        alert.addAction(copyWithDisplayNameAction)

        let copyWithoutDisplayNameAction =
            UIAlertAction(title: "Copy reverse-alias (w/o display name)",
                          style: .default) { _ in
                UIPasteboard.general.string = reverseAliasAddress
                Toast.displayShortly(message: "Copied \(reverseAliasAddress)")
            }
        alert.addAction(copyWithoutDisplayNameAction)

        let openEmaiAction = UIAlertAction(title: "Begin composing with default email",
                                           style: .default) { _ in
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.view.tintColor = SLColor.tintColor

            if mailComposerVC.view == nil {
                return
            }

            mailComposerVC.mailComposeDelegate = mailComposerVCDelegate
            mailComposerVC.setToRecipients([reverseAlias])

            self.present(mailComposerVC, animated: true, completion: nil)
        }
        alert.addAction(openEmaiAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}
