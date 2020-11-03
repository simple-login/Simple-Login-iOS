//
//  ForgotPasswordViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 18/03/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import MBProgressHUD
import SkyFloatingLabelTextField
import Toaster
import UIKit

final class ForgotPasswordViewController: BaseViewController {
    @IBOutlet private weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var resetButton: UIButton!

    private var isValidEmailAddress: Bool = false {
        didSet {
            if isValidEmailAddress {
                resetButton.isEnabled = true
                resetButton.alpha = 1
            } else {
                resetButton.isEnabled = false
                resetButton.alpha = 0.3
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isValidEmailAddress = false
        emailTextField.becomeFirstResponder()
    }

    @IBAction private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func emailTextFieldEditingChanged() {
        if emailTextField.text?.isValidEmail() ?? false {
            emailTextField.errorMessage = nil
            isValidEmailAddress = true
        } else {
            emailTextField.errorMessage = "Invalid email address"
            isValidEmailAddress = false
        }
    }

    @IBAction private func resetButtonTapped() {
        guard let email = emailTextField?.text, email.isValidEmail() else { return }
        MBProgressHUD.showAdded(to: view, animated: true)

        SLClient.shared.forgotPassword(email: email) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                MBProgressHUD.hide(for: self.view, animated: true)
                Toast.displayLongly(message: "We've sent reset password email to \"\(email)\"")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
