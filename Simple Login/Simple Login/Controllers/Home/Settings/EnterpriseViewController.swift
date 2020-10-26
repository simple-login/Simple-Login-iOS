//
//  EnterpriseViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 19/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import MessageUI
import UIKit

final class EnterpriseViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func contactUsButtonTapped() {
        let mailComposerVC = MFMailComposeViewController()

        if mailComposerVC.view == nil {
            return
        }

        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["hi@simplelogin.io"])

        present(mailComposerVC, animated: true, completion: nil)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension EnterpriseViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
