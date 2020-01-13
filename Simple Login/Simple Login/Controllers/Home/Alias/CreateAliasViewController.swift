//
//  CreateAliasViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 12/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Toaster

final class CreateAliasViewController: UIViewController {
    @IBOutlet private weak var rootStackView: UIStackView!
    @IBOutlet private weak var prefixTextField: UITextField!
    @IBOutlet private weak var suffixLabel: UILabel!
    @IBOutlet private weak var createButton: UIButton!
    
    private var isValidEmailPrefix: Bool = false {
        didSet {
            createButton.isEnabled = isValidEmailPrefix
            prefixTextField.textColor = isValidEmailPrefix ? UIColor.black : UIColor.systemRed
        }
    }
    
    deinit {
        print("CreateAliasViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prefixTextField.becomeFirstResponder()
        createButton.isEnabled = false
    }
    
    @IBAction private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func createButtonTapped() {
        Toast.displayShortly(message: "Created")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func prefixTextFieldEditingChanged() {
        guard let text = prefixTextField.text else { return }
        isValidEmailPrefix = text.isValidEmailPrefix()
    }
}
