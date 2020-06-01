//
//  ShareViewController.swift
//  Share Extension
//
//  Created by Thanh-Nhon Nguyen on 08/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Social
import MBProgressHUD

class ShareViewController: UIViewController {
    @IBOutlet private weak var rootStackView: UIStackView!
    @IBOutlet private weak var prefixTextField: UITextField!
    @IBOutlet private weak var suffixView: UIView!
    @IBOutlet private weak var suffixLabel: UILabel!
    @IBOutlet private weak var noteTextField: UITextField!
    @IBOutlet private weak var hintLabel: UILabel!
    @IBOutlet private weak var warningLabel: UILabel!
    @IBOutlet private weak var createButton: UIButton!
    
    private var isValidEmailPrefix: Bool = false {
        didSet {
            createButton.isEnabled = isValidEmailPrefix
            prefixTextField.textColor = isValidEmailPrefix ? SLColor.textColor : SLColor.negativeColor
        }
    }
    
    private var userOptions: UserOptions? {
        didSet {
            prefixTextField.text = userOptions?.prefixSuggestion
            suffixLabel.text = userOptions?.suffixes[0].value[0]
            alertUpgradeIfApplicable()
        }
    }
    
    private var selectedSuffixIndex = 0 {
        didSet {
            suffixLabel.text = userOptions?.suffixes[selectedSuffixIndex].value[0]
        }
    }
    
    deinit {
        print("ShareViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
        if let _ = SLKeychainService.getApiKey() {
            extractUrlString()
        } else {
            let alert = UIAlertController(title: "Sign-in required", message: "You have to sign in before using this feature", preferredStyle: .alert)
            
            let closeAction = UIAlertAction(title: "Close", style: .cancel) { (_) in
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            }
            
            alert.addAction(closeAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func setUpUI() {
        view.tintColor = SLColor.tintColor
        
        rootStackView.isHidden = true
        prefixTextField.textColor = SLColor.textColor
        prefixTextField.delegate = self
        
        // suffixView
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentSuffixListViewController))
        suffixView.isUserInteractionEnabled = true
        suffixView.addGestureRecognizer(tap)
        
        createButton.setTitleColor(SLColor.tintColor, for: .normal)
        
        hintLabel.textColor = SLColor.secondaryTitleColor
        warningLabel.textColor = SLColor.negativeColor
    }
    
    private func extractUrlString() {
        MBProgressHUD.showAdded(to: view, animated: true)
        extensionContext?.inputItems.forEach({ [unowned self] (item) in
            if let extensionItem = item as? NSExtensionItem, let attachments = extensionItem.attachments {
                for itemProvider in attachments {
                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (object, error) in
                        if let url = object as? URL {
                            self.fetchUserOptions(url: url)
                        }
                    }
                }
            }
        })
    }
    
    @IBAction private func cancelButtonTapped() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    @IBAction private func createButtonTapped() {
        createAlias()
    }
    
    @IBAction private func prefixTextFieldEditingChanged() {
        guard let text = prefixTextField.text else { return }
        isValidEmailPrefix = text.isValidEmailPrefix()
    }
    
    @objc private func presentSuffixListViewController() {
        performSegue(withIdentifier: "showSuffixes", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let suffixListViewController as SuffixListViewController:
            suffixListViewController.selectedSuffixIndex = selectedSuffixIndex
            suffixListViewController.suffixes = userOptions?.suffixes
            suffixListViewController.delegate = self
            
        default: return
        }
    }
    
    private func alertUpgradeIfApplicable() {
        guard let userOptions = userOptions, !userOptions.canCreate else { return }
        
        let alert = UIAlertController(title: "Upgrade needed", message: "Open SimpleLogin app ➝ Settings ➝ Upgrade", preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "Close", style: .cancel) { [unowned self] _ in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
        alert.addAction(closeAction)
        
        alert.view.tintColor = SLColor.tintColor
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - API calls
extension ShareViewController {
    private func fetchUserOptions(url: URL) {
        guard let apiKey = SLKeychainService.getApiKey() else {
            MBProgressHUD.hide(for: view, animated: true)
            return
        }
        
        SLApiService.shared.fetchUserOptions(apiKey: apiKey, hostname: url.host ?? "") { [weak self] result in
            guard let self = self else { return }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch result {
            case .success(let userOptions):
                self.rootStackView.isHidden = false
                self.userOptions = userOptions
                
            case .failure(let error):
                self.alertError(error) {
                    self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }
            }
        }
    }
    
    private func createAlias() {
        guard let apiKey = SLKeychainService.getApiKey(), let suffix = userOptions?.suffixes[selectedSuffixIndex] else {
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        let note = noteTextField.text != "" ? noteTextField.text : nil
        
        SLApiService.shared.createAlias(apiKey: apiKey, prefix: prefixTextField.text ?? "", suffix: suffix, note: note) { [weak self] result in
            guard let self = self else { return }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch result {
            case .success(let newlyCreatedAlias):
                let alert = UIAlertController(title: "You are all set!", message: "\"\(newlyCreatedAlias.email)\"\nis created and ready to use", preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Copy & Close", style: .default) { (_) in
                    UIPasteboard.general.string = newlyCreatedAlias.email
                    self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }
                alert.addAction(closeAction)
                self.present(alert, animated: true, completion: nil)
                
            case .failure(let error):
                self.alertError(error) {
                    self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }
            }
        }
    }
}

// MARK: - SuffixListViewControllerDelegate
extension ShareViewController: SuffixListViewControllerDelegate {
    func didSelectSuffix(atIndex index: Int) {
        selectedSuffixIndex = index
    }
}

// MARK: - UITextFieldDelegate
extension ShareViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createAlias()
        return true
    }
}
