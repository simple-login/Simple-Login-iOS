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

final class LoginViewController: UIViewController, Storyboarded {
    @IBOutlet private weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var passwordTextField: SkyFloatingLabelTextField!
    
    @IBOutlet private weak var githubView: RippleView!
    @IBOutlet private weak var googleView: RippleView!
    @IBOutlet private weak var facebookView: RippleView!
    @IBOutlet private var socialLoginViews: [RippleView]!

    deinit {
        print("LoginViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
        googleView.didTap = { [unowned self] in
            print("github")
        }
        
        githubView.didTap = { [unowned self] in
            print("google")
        }
        
        facebookView.didTap = { [unowned self] in
            print("facebook")
        }
    }
    
    private func setUpUI() {
        socialLoginViews.forEach({$0.layer.cornerRadius = 4})
    }
    
    private func login() {
        print(#function)
    }
    
    private func verifyEmailAddress() {
        if emailTextField.text?.isValidEmail() ?? false {
            emailTextField.errorMessage = nil
        } else {
            emailTextField.errorMessage = "Invalid email address"
        }
    }

    @IBAction private func emailTextFieldEditingChanged() {
        guard let email = emailTextField.text, email.contains("@") else {
            emailTextField.errorMessage = nil
            return
        }
        verifyEmailAddress()
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
