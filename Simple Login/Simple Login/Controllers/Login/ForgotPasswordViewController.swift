//
//  ForgotPasswordViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 18/03/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import MBProgressHUD
import Toaster
import FirebaseAnalytics

final class ForgotPasswordViewController: UIViewController {
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
    
    deinit {
        print("ForgotPasswordViewController")
    }
    
    override func viewDidLoad() {
        isValidEmailAddress = false
        emailTextField.becomeFirstResponder()
        Analytics.logEvent("open_forgot_password_view_controller", parameters: nil)
    }
    
    @IBAction private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
        Analytics.logEvent("forgot_password_cancel", parameters: nil)
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
        SLApiService.forgotPassword(email: email) { [weak self] in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            Toast.displayLongly(message: "We've sent reset password email to \"\(email)\"")
            self.dismiss(animated: true, completion: nil)
        }
        Analytics.logEvent("forgot_password_success", parameters: nil)
    }
}
