//
//  AboutViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseAnalytics

final class AboutViewController: BaseLeftMenuButtonViewController, Storyboarded {
    @IBOutlet private weak var tableView: UITableView!

    var openFromLoginViewController = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        Analytics.logEvent("open_about_view_controller", parameters: nil)
    }
    
    private func setUpUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        GeneralInfoTableViewCell.register(with: tableView)
        HowAndSecurityTableViewCell.register(with: tableView)
        WhatAndFaqTableViewCell.register(with: tableView)
        TeamAndContactTableViewCell.register(with: tableView)
        PricingAndBlogTableViewCell.register(with: tableView)
        HelpAndRoadmapTableViewCell.register(with: tableView)
        TermsAndPrivacyTableViewCell.register(with: tableView)
        
        // Don't show hamburger button when this controller is open from LoginViewController
        if openFromLoginViewController {
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let webViewController as WebViewController:
            
            switch segue.identifier {
            case "showTeam": webViewController.module = .team
            case "showPricing": webViewController.module = .pricing
            case "showBlog": webViewController.module = .blog
            case "showTerms": webViewController.module = .terms
            case "showPrivacy": webViewController.module = .privacy
            case "showSecurity": webViewController.module = .security
            case "showHelp": webViewController.module = .help
            default: return
            }
            
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

// MARK: - UITableViewDataSource
extension AboutViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: return GeneralInfoTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
        case 1:
            let cell = HowAndSecurityTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didTapHowItWorksLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showHow", sender: nil)
            }
            
            cell.didTapSecurityLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showSecurity", sender: nil)
            }
            
            return cell
            
        case 2:
            let cell = WhatAndFaqTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didTapWhatLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showWhat", sender: nil)
                Analytics.logEvent("about_view_what", parameters: nil)
            }
            
            cell.didTapFaqLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showFaq", sender: nil)
                Analytics.logEvent("about_view_faq", parameters: nil)
            }
            
            return cell
            
        case 3:
            let cell = TeamAndContactTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didTapTeamLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showTeam", sender: nil)
                Analytics.logEvent("about_view_team", parameters: nil)
            }
            
            cell.didTapContactLabel = { [unowned self] in
                self.openContactForm()
                Analytics.logEvent("about_compose_email", parameters: nil)
            }
            
            return cell
            
        case 4:
            let cell = PricingAndBlogTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didTapPricingLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showPricing", sender: nil)
                Analytics.logEvent("about_view_pricing", parameters: nil)
            }
            
            cell.didTapBlogLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showBlog", sender: nil)
                Analytics.logEvent("about_view_blog", parameters: nil)
            }
            
            return cell
            
        case 5:
            let cell = HelpAndRoadmapTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didTapHelpLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showHelp", sender: nil)
                Analytics.logEvent("about_view_help", parameters: nil)
            }
            
            cell.didTapRoadmapLabel = {
                guard let url = URL(string: "https://trello.com/b/4d6A69I4/open-roadmap") else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                Analytics.logEvent("about_view_roadmap", parameters: nil)
            }
            
            return cell
            
        case 6:
            let cell = TermsAndPrivacyTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didTapTermsLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showTerms", sender: nil)
                Analytics.logEvent("about_view_terms", parameters: nil)
            }
            
            cell.didTapPrivacyLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showPrivacy", sender: nil)
                Analytics.logEvent("about_view_privacy", parameters: nil)
            }
            
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
