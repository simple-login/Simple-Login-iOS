//
//  AboutViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import MessageUI

final class AboutViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    deinit {
        print("AboutViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        GeneralInfoTableViewCell.register(with: tableView)
        HowAndFaqTableViewCell.register(with: tableView)
        TeamAndContactTableViewCell.register(with: tableView)
        PricingAndBlogTableViewCell.register(with: tableView)
        TermsAndPrivacyTableViewCell.register(with: tableView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let webViewController = segue.destination as? WebViewController else { return }
//        switch segue.identifier {
//        case "showTeam": webViewController.module = .team
//        case "showPricing": webViewController.module = .pricing
//        case "showBlog": webViewController.module = .blog
//        case "showTerms": webViewController.module = .terms
//        case "showPrivacy": webViewController.module = .privacy
//        default: return
//        }
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

// MARK: - UITableViewDataSource
extension AboutViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: return GeneralInfoTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        case 1:
            let cell = HowAndFaqTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didTapHowItWorksLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showHow", sender: nil)
            }
            
            cell.didTapFaqLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showFaq", sender: nil)
            }
            
            return cell
        case 2:
            let cell = TeamAndContactTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didTapContactLabel = { [unowned self] in
                self.openContactForm()
            }
            
            return cell
        case 3:
            let cell = PricingAndBlogTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            return cell
        case 4:
            let cell = TermsAndPrivacyTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            return cell
        default: return UITableViewCell()
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension AboutViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
