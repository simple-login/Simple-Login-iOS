//
//  LoginViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 03/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import MaterialComponents.MaterialRipple
import MBProgressHUD
import Toaster
import FacebookLogin
import GoogleSignIn
import FirebaseAnalytics

final class LoginViewController: UIViewController, Storyboarded {
    @IBOutlet private weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var loginButton: UIButton!
    
    @IBOutlet private weak var socialLoginLabel: UILabel!
    @IBOutlet private weak var githubView: RippleView!
    @IBOutlet private weak var googleView: RippleView!
    @IBOutlet private weak var facebookView: RippleView!
    @IBOutlet private var socialLoginViews: [RippleView]!
    
    @IBOutlet private weak var versionLabel: UILabel!
    
    private var isValidEmailAddress: Bool = true {
        didSet {
            loginButton.isEnabled = isValidEmailAddress
        }
    }

    deinit {
        print("LoginViewController is deallocated")
        NotificationCenter.default.removeObserver(self, name: .didSignInWithGoogle, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        hideSocialLogins()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSignInWithGoogle), name: .didSignInWithGoogle, object: nil)
        
        Analytics.logEvent("open_login_view_controller", parameters: nil)
    }
    
    private func hideSocialLogins() {
        socialLoginLabel.isHidden = true
        
        githubView.isHidden = true
        githubView.didTap = { [unowned self] in
            self.oauthWithGithub()
        }
        
        googleView.isHidden = true
        googleView.didTap = { [unowned self] in
            self.oauthWithGoogle()
        }
        
        facebookView.isHidden = true
        facebookView.didTap = { [unowned self] in
            self.oauthWithFacebook()
        }
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
        socialLoginViews.forEach({$0.layer.cornerRadius = 4})
        
        loginButton.setTitleColor(SLColor.tintColor, for: .normal)
        loginButton.setTitleColor(SLColor.tintColor.withAlphaComponent(0.3), for: .disabled)
        
        versionLabel.text = "SimpleLogin v\(versionString)"
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
    
        SLApiService.login(email: email, password: password) { [weak self] (userLogin, error) in
            guard let self = self else { return }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            self.finalizeLoginApiCall(userLogin: userLogin, error: error)
        }
        
        Analytics.logEvent("log_in_with_email_password", parameters: nil)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @objc private func didSignInWithGoogle(_ notification: Notification) {
        if let accessToken = notification.object as? String {
            socialLogin(social: .google, accessToken: accessToken)
        }
    }
    
    @IBAction private func aboutUsButtonTapped() {
        let aboutViewController = AboutViewController.instantiate(storyboardName: "About")
        aboutViewController.openFromLoginViewController = true
        navigationController?.pushViewController(aboutViewController, animated: true)
    }
    
    private func verify(mode: VerificationViewController.VerificationMode) {
        guard let verificationNavigationController = storyboard?.instantiateViewController(withIdentifier: "VerificationNavigationController") as? UINavigationController,
            let verificationViewController = verificationNavigationController.viewControllers[0] as? VerificationViewController else { return }
        
        verificationNavigationController.modalPresentationStyle = .fullScreen
        verificationViewController.mode = mode
        
        switch mode {
        case .otp(_):
            verificationViewController.otpVerificationSuccesful = { [unowned self] apiKey in
                self.finalizeLogin(apiKey: apiKey)
            }
            
        case .accountActivation(let email, let password):
            verificationViewController.accountVerificationSuccesful = { [unowned self] in
                self.emailTextField.text = email
                self.passwordTextField.text = password
                self.login()
            }
        }
        
        present(verificationNavigationController, animated: true, completion: nil)
    }
    
    private func finalizeLogin(apiKey: String) {
        do {
            try SLKeychainService.setApiKey(apiKey)
        } catch {
            Toast.displayShortly(message: "Error setting API key to keychain")
        }
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func finalizeLoginApiCall(userLogin: UserLogin?, error: SLError?) {
        if let userLogin = userLogin {
            if userLogin.isMfaEnabled {
                if let mfaKey = userLogin.mfaKey {
                    self.verify(mode: .otp(mfaKey: mfaKey))
                } else {
                    Toast.displayLongly(message: "MFA key is null")
                }
                
            } else {
                if let apiKey = userLogin.apiKey {
                    self.finalizeLogin(apiKey: apiKey)
                } else {
                    Toast.displayShortly(message: "API key is null")
                }
            }
            
        } else if let error = error {
            Toast.displayShortly(message: error.description)
        }
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
        
        SLApiService.signUp(email: email, password: password) { [weak self] (error) in
            guard let self = self else { return }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let error = error {
                Toast.displayError(error)
                Analytics.logEvent("sign_up_error", parameters: error.toParameter())
            } else {
                Toast.displayLongly(message: "Check your inbox for verification code")
                Analytics.logEvent("sign_up_success", parameters: nil)
                self.verify(mode: .accountActivation(email: email, password: password))
            }
        }
    }
}

// MARK: - OAuth
extension LoginViewController {
    private func socialLogin(social: SLOAuthService, accessToken: String) {
        MBProgressHUD.showAdded(to: view, animated: true)
        
        SLApiService.socialLogin(service: social, accessToken: accessToken) { [weak self] (userLogin, error) in
            guard let self = self else { return }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            self.finalizeLoginApiCall(userLogin: userLogin, error: error)
        }
    }
    
    private func oauthWithGithub() {

    }
    
    private func oauthWithGoogle() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    private func oauthWithFacebook() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email"], from: self) { [weak self] (result, error) in
            guard let self = self else { return }
            if let error = error {
                Toast.displayError(error.localizedDescription)
            } else if let result = result {
                if result.isCancelled {
                    Toast.displayShortly(message: "Log in with Facebook cancelled")
                    Analytics.logEvent("log_in_with_facebook_cancelled", parameters: nil)
                } else {
                    if let accessToken = result.token {
                        self.socialLogin(social: .facebook, accessToken: accessToken.tokenString)
                        Analytics.logEvent("log_in_with_facebook_success", parameters: nil)
                    } else {
                        Toast.displayShortly(message: "Facebook access token is null")
                        Analytics.logEvent("log_in_with_facebook_access_token_null", parameters: nil)
                    }
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
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            verifyEmailAddress()
        } else if textField == passwordTextField {
            login()
        }
        
        return true
    }
}
