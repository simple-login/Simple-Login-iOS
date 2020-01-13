//
//  HowToSendEmailViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class HowToSendEmailViewController: UIViewController {
    @IBOutlet private weak var explicationLabel: UILabel!
    
    deinit {
        print("HowToSendEmailViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setExplicationLabel()
    }
    
    @IBAction private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setExplicationLabel() {
        let plainString = """
        Follow these 2 simple steps:
        
        1️⃣ Create a reverse-alias by entering an email address that you want to send to.

        2️⃣ Send email as you always do to that reverse-alias from your personal email address (the one that you use to register with SimpleLogin)

        And that's all!
        We will take care of the rest to make magic happen
        🎩✨✨✨

        ⚠️ Note that your reverse-aliases can only be used by you.
        """
        
        let attributedString = NSMutableAttributedString(string: plainString)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.justified
        
        attributedString.addAttributes([
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.darkGray], range: NSRange(plainString.startIndex..., in: plainString))
        
        // Highlight
        ["reverse-alias", "reverse-aliases"].forEach { (string) in
            RegexHelpers.matchRanges(of: string, inString: plainString).forEach { (range) in
                attributedString.addAttribute(.backgroundColor, value: UIColor.systemYellow, range: range)
            }
        }
        
        ["from your personal email address", "only"].forEach { (string) in
            RegexHelpers.matchRanges(of: string, inString: plainString).forEach { (range) in
                attributedString.addAttributes([
                    .backgroundColor: UIColor.systemRed,
                    .foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium)], range: range)
            }
        }
        
        explicationLabel.attributedText = attributedString
    }
}
