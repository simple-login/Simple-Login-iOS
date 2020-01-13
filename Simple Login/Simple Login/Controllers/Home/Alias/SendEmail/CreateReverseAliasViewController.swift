//
//  CreateReverseAliasViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Toaster

final class CreateReverseAliasViewController: UIViewController {
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var destinationEmailTextField: UITextField!
    @IBOutlet private weak var createButton: UIButton!
    
    var alias: Alias!
    
    private var isValidEmailAddress: Bool = false {
        didSet {
            destinationEmailTextField.textColor = isValidEmailAddress ? UIColor.black : UIColor.systemRed
            createButton.isEnabled = isValidEmailAddress
        }
    }
    
    deinit {
        print("CreateReverseAliasViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        createButton.isEnabled = false
        destinationEmailTextField.becomeFirstResponder()
    }
    
    private func setUpUI() {
        let plainString = "Create a reverse-alias to send email from your alias\n\(alias.name)"
        
        let attributedString = NSMutableAttributedString(string: plainString)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.darkText], range: NSRange(plainString.startIndex..., in: plainString))
        
        if let aliasNameRange = plainString.range(of: alias.name) {
            attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 15, weight: .bold),
            .foregroundColor: UIColor.black], range: NSRange(aliasNameRange, in: plainString))
        }
    
        messageLabel.attributedText = attributedString
    }
    
    private func create() {
        Toast.displayShortly(message: "Created")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func createButtonTapped() {
        create()
    }
    
    @IBAction private func destinationEmailTextFieldEditingChanged() {
        guard let enteredEmail = destinationEmailTextField.text else { return }
        
        isValidEmailAddress = enteredEmail.isValidEmail()
    }
    
}
