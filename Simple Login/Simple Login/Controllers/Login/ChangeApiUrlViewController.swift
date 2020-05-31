//
//  ChangeApiUrlViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Toaster

final class ChangeApiUrlViewController: BaseViewController {
    @IBOutlet private weak var warningLabel: UILabel!
    @IBOutlet private weak var defaultLabel: UILabel!
    @IBOutlet private weak var urlTextField: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        urlTextField.text = UserDefaults.getApiUrl()
    }
    
    private func setUpUI() {
        // warningLabel
        let warningString = "DO NOT change API URL unless you are hosting SimpleLogin with your own server."
        let warningAttributedString = NSMutableAttributedString(string: warningString)
        warningAttributedString.addAttributes([
            .font : UIFont.systemFont(ofSize: 15),
            .foregroundColor : SLColor.negativeColor], range: NSRange(warningString.startIndex..., in: warningString))
        
        if let range = warningString.range(of: "DO NOT") {
            warningAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .bold), range: NSRange(range, in: warningString))
        }
        
        warningLabel.attributedText = warningAttributedString
        
        // defaultlabel
        let defaultString = "The default value is https://app.simplelogin.io"
        let defaultAttributedString = NSMutableAttributedString(string: defaultString)
        defaultAttributedString.addAttributes([
            .font : UIFont.systemFont(ofSize: 15),
            .foregroundColor : SLColor.textColor], range: NSRange(defaultString.startIndex..., in: defaultString))
        
        if let range = defaultString.range(of: "https://app.simplelogin.io") {
            defaultAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .bold), range: NSRange(range, in: defaultString))
        }
        
        defaultLabel.attributedText = defaultAttributedString
    }
    
    @IBAction private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func applyButtonTapped() {
        guard let apiUrl = urlTextField.text else {
            Toast.displayShortly(message: "API URL is empty")
            return
        }
        UserDefaults.setApiUrl(apiUrl)
        SLApiService.shared.refreshBaseUrl()
        dismiss(animated: true) {
            Toast.displayShortly(message: "Changed API URL to: \(apiUrl)")
        }
    }
    
    @IBAction private func resetButtonTapped() {
        UserDefaults.resetApiUrl()
        SLApiService.shared.refreshBaseUrl()
        dismiss(animated: true) {
            Toast.displayShortly(message: "Reset API URL to: \(UserDefaults.getApiUrl())")
        }
    }
}
