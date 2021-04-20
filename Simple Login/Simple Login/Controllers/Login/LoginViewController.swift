//
//  LoginViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 03/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import MBProgressHUD
import SkyFloatingLabelTextField
import Toaster
import UIKit

final class LoginViewController: BaseViewController, Storyboarded {
    @IBOutlet private weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var versionLabel: UILabel!
    private var showHidePasswordImageView: UIImageView!
    private var isShowingPassword = false {
        didSet {
            passwordTextField.isSecureTextEntry = !isShowingPassword
        }
    }

    private var isValidEmailAddress = true {
        didSet {
            loginButton.isEnabled = isValidEmailAddress
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setUpUI() {
        loginButton.setTitleColor(SLColor.tintColor, for: .normal)
        loginButton.setTitleColor(SLColor.tintColor.withAlphaComponent(0.3), for: .disabled)

        // Show/hide password
        showHidePasswordImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        showHidePasswordImageView.contentMode = .scaleAspectFit
        showHidePasswordImageView.tintColor = UIColor.lightGray.withAlphaComponent(0.6)
        showHidePasswordImageView.image = UIImage(named: "ic_eye_fill")
        let imageContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 20))
        imageContainerView.addSubview(showHidePasswordImageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleShowHidePassword))
        imageContainerView.isUserInteractionEnabled = true
        imageContainerView.addGestureRecognizer(tap)
        passwordTextField.rightView = imageContainerView
        passwordTextField.rightViewMode = .always

        versionLabel.text = "SimpleLogin v\(kVersionString)"
    }

    @objc
    private func toggleShowHidePassword() {
        isShowingPassword.toggle()
        let imageName = isShowingPassword ? "ic_eye_slash_fill" : "ic_eye_fill"
        showHidePasswordImageView.image = UIImage(named: imageName)
    }

    @IBAction private func login() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        guard isValidEmailAddress else {
            Toast.displayShortly(message: "Invalid email address")
            return
        }

        guard let email = emailTextField.text, let password = passwordTextField.text else { return }

        MBProgressHUD.showAdded(to: view, animated: true)

        SLClient.shared.login(email: email,
                              password: password,
                              deviceName: UIDevice.current.name) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                MBProgressHUD.hide(for: self.view, animated: true)

                switch result {
                case .success(let userLogin):
                    if userLogin.isMfaEnabled {
                        if let mfaKey = userLogin.mfaKey {
                            self.verify(mode: .otp(mfaKey: mfaKey))
                        } else {
                            Toast.displayLongly(message: "MFA key is null")
                        }
                    } else if let apiKey = userLogin.apiKey {
                        self.finalizeLogin(apiKey: apiKey)
                    } else {
                        Toast.displayLongly(message: "API key is null")
                    }

                case .failure(let error):
                    switch error {
                    case let .unknownErrorWithStatusCode(statusCode) where statusCode == 403:
                        self.alertWebAuthnNotSupported()
                    default:
                        Toast.displayShortly(message: error.description)
                    }
                }
            }
        }
    }

    private func alertWebAuthnNotSupported() {
        let alert = UIAlertController(
            title: "WebAuthn currently not supported",
            message: "Please log in using API key while we are working on supporting WebAuthn on mobile.",
            preferredStyle: .alert)
        let apiKeyAction = UIAlertAction(title: "Enter API key",
                                         style: .default) { [unowned self] _ in
            self.signInWithApiKeyButtonTapped()
        }
        alert.addAction(apiKeyAction)
        let closeAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(closeAction)
        present(alert, animated: true, completion: nil)
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

    @IBAction private func emailTextFieldEditingChanged() {
        guard let email = emailTextField.text, email.contains("@") else {
            emailTextField.errorMessage = nil
            return
        }
        verifyEmailAddress()
    }

    @IBAction private func signInWithApiKeyButtonTapped() {
        let alert = UIAlertController(
            title: "Enter API key",
            // swiftlint:disable:next line_length
            message: "To get your API key, you have to sign in SimpleLogin via a browser then navigate to \"API Key\" tab",
            preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "API key"
        }

        let setAction = UIAlertAction(title: "Set API key", style: .default) { [unowned self] _ in
            guard let apiKeyValue = alert.textFields?[0].text else { return }
            let apiKey = ApiKey(value: apiKeyValue)

            MBProgressHUD.showAdded(to: self.view, animated: true)

            SLClient.shared.fetchUserInfo(apiKey: apiKey) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    MBProgressHUD.hide(for: self.view, animated: true)

                    switch result {
                    case .success: self.finalizeLogin(apiKey: apiKey)
                    case .failure(let error): Toast.displayError(error)
                    }
                }
            }
        }
        alert.addAction(setAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    @IBAction private func aboutUsButtonTapped() {
        let aboutViewController = AboutViewController.instantiate(storyboardName: "About")
        aboutViewController.openFromLoginViewController = true
        navigationController?.pushViewController(aboutViewController, animated: true)
    }

    private func verify(mode: VerificationViewController.VerificationMode) {
        // swiftlint:disable:next line_length
        guard let verificationNavigationController = storyboard?.instantiateViewController(withIdentifier: "VerificationNavigationController") as? UINavigationController, let verificationViewController = verificationNavigationController.viewControllers[0] as? VerificationViewController else { return }

        verificationNavigationController.modalPresentationStyle = .fullScreen
        verificationViewController.mode = mode

        switch mode {
        case .otp:
            verificationViewController.otpVerificationSuccesful = { [unowned self] apiKey in
                self.finalizeLogin(apiKey: apiKey)
            }

        case let .accountActivation(email, password):
            verificationViewController.accountVerificationSuccesful = { [unowned self] in
                self.emailTextField.text = email
                self.passwordTextField.text = password
                self.login()
            }
        }

        present(verificationNavigationController, animated: true, completion: nil)
    }

    private func finalizeLogin(apiKey: ApiKey) {
        do {
            try SLKeychainService.setApiKey(apiKey)
        } catch {
            Toast.displayShortly(message: "Error setting API key to keychain.\n\(error.localizedDescription)")
        }

        navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Sign Up
extension LoginViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let signUpViewController as SignUpViewController:
            signUpViewController.signUp = { [unowned self] email, password in
                self.signUp(email: email, password: password)
            }

        default: return
        }
    }

    private func signUp(email: String, password: String) {
        MBProgressHUD.showAdded(to: view, animated: true)

        SLClient.shared.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                MBProgressHUD.hide(for: self.view, animated: true)

                switch result {
                case .success:
                    Toast.displayLongly(message: "Check your inbox for verification code")
                    self.verify(mode: .accountActivation(email: email, password: password))

                case .failure(let error):
                    Toast.displayError(error)
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField {
            verifyEmailAddress()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField: passwordTextField.becomeFirstResponder(); verifyEmailAddress()
        case passwordTextField: login()
        default: break
        }
        return true
    }
}
