//
//  AboutViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import MessageUI

final class AboutViewController: BaseTableViewController {
    
    deinit {
        print("AboutViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let webViewController = segue.destination as? WebViewController else { return }
        switch segue.identifier {
        case "showTeam": webViewController.module = .team
        case "showPricing": webViewController.module = .pricing
        case "showBlog": webViewController.module = .blog
        case "showTerms": webViewController.module = .terms
        case "showPrivacy": webViewController.module = .privacy
        default: return
        }
    }
    
    private func openContactForm() {
        let mailComposerVC = MFMailComposeViewController()
        
        guard let _ = mailComposerVC.view else {
            return
        }
        
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["hi@simplelogin.io"])
        
        present(mailComposerVC, animated: true, completion: nil)
    }
}

extension AboutViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (2, 1): openContactForm()
        default: return
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension AboutViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
