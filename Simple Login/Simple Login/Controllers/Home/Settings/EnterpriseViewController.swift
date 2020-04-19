//
//  EnterpriseViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 19/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import MessageUI

final class EnterpriseViewController: UIViewController {
    deinit {
        print("EnterpriseViewController is deallocated")
    }
    
    @IBAction private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func contactUsButtonTapped() {
        let mailComposerVC = MFMailComposeViewController()
        
        guard let _ = mailComposerVC.view else {
            return
        }
        
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["hi@simplelogin.io"])
        
        present(mailComposerVC, animated: true, completion: nil)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension EnterpriseViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
