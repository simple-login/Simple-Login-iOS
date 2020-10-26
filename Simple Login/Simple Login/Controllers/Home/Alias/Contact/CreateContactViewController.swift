//
//  CreateContactViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import MBProgressHUD
import Toaster
import UIKit

final class CreateContactViewController: BaseApiKeyViewController {
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var destinationEmailTextField: UITextField!
    @IBOutlet private weak var createButton: UIButton!

    var alias: Alias!

    var didCreateContact: (() -> Void)?

    private var isValidEmailAddress: Bool = false {
        didSet {
            destinationEmailTextField.textColor = isValidEmailAddress ? SLColor.textColor : SLColor.negativeColor
            createButton.isEnabled = isValidEmailAddress
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        createButton.isEnabled = false
        destinationEmailTextField.becomeFirstResponder()
    }

    private func setUpUI() {
        let plainString = "Create a contact to send email from your alias\n\(alias.email)"

        let attributedString = NSMutableAttributedString(string: plainString)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center

        attributedString.addAttributes(
            [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: SLColor.titleColor
            ],
            range: NSRange(plainString.startIndex..., in: plainString))

        if let aliasNameRange = plainString.range(of: alias.email) {
            attributedString.addAttributes(
                [
                    .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                    .foregroundColor: SLColor.textColor
                ],
                range: NSRange(aliasNameRange, in: plainString))
        }

        messageLabel.attributedText = attributedString
    }

    private func create(_ email: String) {
        destinationEmailTextField.resignFirstResponder()

        MBProgressHUD.showAdded(to: view, animated: true)

        SLApiService.shared.createContact(apiKey: apiKey, aliasId: alias.id, email: email) { [weak self] result in
            guard let self = self else { return }

            MBProgressHUD.hide(for: self.view, animated: true)

            switch result {
            case .success:
                Toast.displayShortly(message: "Created contact \(email)")
                self.dismiss(animated: true) {
                    self.didCreateContact?()
                }

            case .failure(let error):
                Toast.displayError(error)
            }
        }
    }

    @IBAction private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func createButtonTapped() {
        guard let email = destinationEmailTextField.text, email.isValidEmail() else {
            let alert = UIAlertController(
                title: "Invalid email address",
                message: "Please verify that you have correctly entered",
                preferredStyle: .alert)
            let closeButton = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            alert.addAction(closeButton)
            present(alert, animated: true, completion: nil)
            return
        }

        create(email)
    }

    @IBAction private func destinationEmailTextFieldEditingChanged() {
        guard let enteredEmail = destinationEmailTextField.text else { return }

        isValidEmailAddress = enteredEmail.isValidEmail()
    }
}
