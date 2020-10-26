//
//  SignUpViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 29/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import SkyFloatingLabelTextField
import UIKit

final class SignUpViewController: BaseViewController, Storyboarded {
    @IBOutlet private weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var signUpButton: UIButton!

    private var isValidEmailAddress: Bool = false {
        didSet {
            isSignUpable = isValidEmailAddress && isValidPassword
        }
    }

    private var isValidPassword: Bool = false {
        didSet {
            isSignUpable = isValidEmailAddress && isValidPassword
        }
    }

    private var isSignUpable: Bool = false {
        didSet {
            if isSignUpable {
                signUpButton.isEnabled = true
                signUpButton.alpha = 1
            } else {
                signUpButton.isEnabled = false
                signUpButton.alpha = 0.5
            }
        }
    }

    var signUp: ((_ email: String, _ password: String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        isSignUpable = false
    }

    @IBAction private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func emailTextFieldEditingChanged() {
        guard let email = emailTextField.text, email.contains("@") else {
            emailTextField.errorMessage = nil
            return
        }
        verifyEmailAddress()
    }

    private func verifyEmailAddress() {
        if emailTextField.text?.isValidEmail() ?? false {
            emailTextField.errorMessage = nil
            isValidEmailAddress = true
        } else {
            emailTextField.errorMessage = "Invalid email address"
            isValidEmailAddress = false
        }
    }

    @IBAction private func passwordTextFieldEditingChanged() {
        if passwordTextField.text?.count ?? 0 >= 8 {
            passwordTextField.errorMessage = nil
            isValidPassword = true
        } else {
            passwordTextField.errorMessage = "Minimum 8 characters"
            isValidPassword = false
        }
    }

    @IBAction private func signUpButtonTapped() {
        guard isSignUpable, let email = emailTextField.text, let password = passwordTextField.text else { return }

        dismiss(animated: true) {
            self.signUp?(email, password)
        }
    }
}
