//
//  DirectoryExplanationViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 26/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD

final class DirectoryExplanationViewController: BaseApiKeyViewController {
    @IBOutlet private weak var rootStackView: UIStackView!
    @IBOutlet private weak var openingLabel: UILabel!
    @IBOutlet private weak var listLabel: UILabel!
    @IBOutlet private weak var closingLabel: UILabel!
    @IBOutlet private weak var domainListLabel: UILabel!
    @IBOutlet private weak var informationLabel: UILabel!
    
    private var userOptions: UserOptions!

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserOptions()
    }
    
    @IBAction private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func fetchUserOptions() {
        MBProgressHUD.showAdded(to: view, animated: true)
        rootStackView.isHidden = true
        
        SLApiService.shared.fetchUserOptions(apiKey: apiKey) { [weak self] result in
            guard let self = self else { return }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch result {
            case .success(let userOptions):
                self.rootStackView.isHidden = false
                self.userOptions = userOptions
                self.setUpUI()
                
            case .failure(let error):
                Toast.displayError(error)
            }
        }
    }
    
    private func setUpUI() {
        // Opening
        let openingText = "Directory allows you to create aliases on the fly. Simply use:"
        let openingAttributedString = NSMutableAttributedString(string: openingText)
        
        openingAttributedString.addAttributes([.foregroundColor: SLColor.textColor, .font: UIFont.systemFont(ofSize: 15)], range: NSRange(openingText.startIndex..., in: openingText))
        
        if let onTheFlyRange = openingText.range(of: "on the fly") {
            openingAttributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 15), range: NSRange(onTheFlyRange, in: openingText))
        }
        
        openingLabel.attributedText = openingAttributedString
        
        // List
        let firstDomain = userOptions.domains[0]
        let listText = """
            your_directory/anything@\(firstDomain) or
            your_directory+anything@\(firstDomain) or
            your_directory#anything@\(firstDomain)
            """
        let listAttributedString = NSMutableAttributedString(string: listText)
        
        listAttributedString.addAttributes([.foregroundColor: SLColor.textColor, .font: UIFont.systemFont(ofSize: 15)], range: NSRange(listText.startIndex..., in: listText))
        
        if let firstMatchRange = listText.range(of: "your_directory/anything@\(firstDomain)"),
            let secondMatchRange = listText.range(of: "your_directory+anything@\(firstDomain)"),
            let thirdMatchRange = listText.range(of: "your_directory#anything@\(firstDomain)") {
            
            let backgroundColor = UIColor.systemYellow
            listAttributedString.addAttribute(.backgroundColor, value: backgroundColor, range: NSRange(firstMatchRange, in: listText))
            listAttributedString.addAttribute(.backgroundColor, value: backgroundColor, range: NSRange(secondMatchRange, in: listText))
            listAttributedString.addAttribute(.backgroundColor, value: backgroundColor, range: NSRange(thirdMatchRange, in: listText))
        }
        
        let anythingInListRanges = RegexHelpers.matchRanges(of: "anything", inString: listText)
        anythingInListRanges.forEach { (range) in
            listAttributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 15), range: range)
        }
        
        listLabel.attributedText = listAttributedString
        
        // Closing
        let closingText = """
            next time you need an email address.
            anything could really be anything, it's up to you to invent the most creative alias 😉.
            your_directory is the name of one of your directories.
            """
        let closingAttributedString = NSMutableAttributedString(string: closingText)
        
        closingAttributedString.addAttributes([.foregroundColor: SLColor.textColor, .font: UIFont.systemFont(ofSize: 15)], range: NSRange(closingText.startIndex..., in: closingText))
        
        if let firstMatchRange = closingText.range(of: "anything"),
            let secondMatchRange = closingText.range(of: "your_directory") {
            
            let backgroundColor = UIColor.systemYellow
            closingAttributedString.addAttribute(.backgroundColor, value: backgroundColor, range: NSRange(firstMatchRange, in: closingText))
            closingAttributedString.addAttribute(.backgroundColor, value: backgroundColor, range: NSRange(secondMatchRange, in: closingText))
        }
        
        if let anythingRange = closingText.range(of: "anything") {
            closingAttributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 15), range: NSRange(anythingRange, in: closingText))
        }
        
        closingLabel.attributedText = closingAttributedString
        
        // Domain list
        var domainListText = "ou can use the directory feature on the following domains:"
        userOptions.domains.forEach { (domain) in
            domainListText += "\n\(domain)"
        }
        
        let domainListAttributedString = NSMutableAttributedString(string: domainListText)
        domainListAttributedString.addAttributes([.foregroundColor: SLColor.textColor, .font: UIFont.systemFont(ofSize: 15)], range: NSRange(domainListText.startIndex..., in: domainListText))
        
        userOptions.domains.forEach { (domain) in
            if let range = domainListText.range(of: domain) {
                domainListAttributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 15), range: NSRange(range, in: domainListText))
            }
        }
        
        domainListLabel.attributedText = domainListAttributedString
    }
}
