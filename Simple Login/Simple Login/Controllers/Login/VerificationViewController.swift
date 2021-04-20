//
//  OtpViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 05/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import MaterialComponents.MaterialSnackbar
import MBProgressHUD
import Toaster
import UIKit

/// This stackView's subclass is used for displaying tooltip (UIMenuController)
/// canBecomeFirstResponder must always return true
final class ResponsiveStackView: UIStackView {
    override var canBecomeFirstResponder: Bool { true }
}

private extension UIPasteboard {
    static func retrieveCopiedCode() -> String? {
        guard let copiedText = UIPasteboard.general.string,
              copiedText.count == 6,
              Int(copiedText) != nil else { return nil }

        return copiedText
    }
}

extension VerificationViewController {
    enum VerificationMode {
        case otp(mfaKey: String), accountActivation(email: String, password: String)
    }
}

final class VerificationViewController: BaseViewController, Storyboarded {
    @IBOutlet private weak var numberRootStackView: ResponsiveStackView!
    @IBOutlet private weak var firstNumberLabel: UILabel!
    @IBOutlet private weak var secondNumberLabel: UILabel!
    @IBOutlet private weak var thirdNumberLabel: UILabel!
    @IBOutlet private weak var fourthNumberLabel: UILabel!
    @IBOutlet private weak var fifthNumberLabel: UILabel!
    @IBOutlet private weak var sixthNumberLabel: UILabel!
    private lazy var numberLabels: [UILabel] =
        [firstNumberLabel, secondNumberLabel, thirdNumberLabel,
         fourthNumberLabel, fifthNumberLabel, sixthNumberLabel]

    @IBOutlet private weak var errorLabel: UILabel!

    @IBOutlet private weak var zeroButton: UIButton!
    @IBOutlet private weak var oneButton: UIButton!
    @IBOutlet private weak var twoButton: UIButton!
    @IBOutlet private weak var threeButton: UIButton!
    @IBOutlet private weak var fourButton: UIButton!
    @IBOutlet private weak var fiveButton: UIButton!
    @IBOutlet private weak var sixButton: UIButton!
    @IBOutlet private weak var sevenButton: UIButton!
    @IBOutlet private weak var eightButton: UIButton!
    @IBOutlet private weak var nineButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!

    @IBOutlet private var buttons: [UIButton]!

    var otpVerificationSuccesful: ((_ apiKey: ApiKey) -> Void)?
    var accountVerificationSuccesful: (() -> Void)?

    var mode: VerificationMode!
    private var observers: [Any?] = []
    private let numberPlaceholder = "-"

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .applicationDidBecomeActive,
                                               object: nil)
    }

    private func setUpUI() {
        buttons.forEach { button in
            button.layer.cornerRadius = button.bounds.width / 2
            button.backgroundColor = SLColor.textColor.withAlphaComponent(0.1)
        }

        errorLabel.alpha = 0

        switch mode {
        case .otp: title = "Enter OTP"
        case .accountActivation: title = "Enter activation code"
        case .none: title = nil
        }

        // Long press gesture to display "Paste" tooltip
        let longPressGesture =
            UILongPressGestureRecognizer(target: self, action: #selector(numberRootStackViewLongPressed))
        longPressGesture.minimumPressDuration = 0.3
        numberRootStackView.isUserInteractionEnabled = true
        numberRootStackView.addGestureRecognizer(longPressGesture)
    }

    @objc
    private func applicationDidBecomeActive() {
        guard let copiedCode = UIPasteboard.retrieveCopiedCode() else { return }

        let message = MDCSnackbarMessage()
        message.text = "\"\(copiedCode)\" is found from the clipboard"
        let action = MDCSnackbarMessageAction()
        action.handler = { [unowned self] () in
            self.pasteAndVerify()
        }
        action.title = "Paste & Verify"
        message.action = action
        MDCSnackbarManager.default.show(message)
    }

    @objc
    private func numberRootStackViewLongPressed(sender: UILongPressGestureRecognizer) {
        guard UIPasteboard.retrieveCopiedCode() != nil, sender.state == .began else { return }

        let pasteMenuItem = UIMenuItem(title: "Paste & verify", action: #selector(pasteAndVerify))
        UIMenuController.shared.menuItems = [pasteMenuItem]
        UIMenuController.shared.setTargetRect(numberRootStackView.frame, in: numberRootStackView.superview ?? view)
        UIMenuController.shared.setMenuVisible(true, animated: true)
        numberRootStackView.becomeFirstResponder()
    }

    @objc
    private func pasteAndVerify() {
        guard let copiedCode = UIPasteboard.retrieveCopiedCode() else { return }

        showErrorLabel(nil)

        firstNumberLabel.text = String(copiedCode[0])
        secondNumberLabel.text = String(copiedCode[1])
        thirdNumberLabel.text = String(copiedCode[2])
        fourthNumberLabel.text = String(copiedCode[3])
        fifthNumberLabel.text = String(copiedCode[4])
        sixthNumberLabel.text = String(copiedCode[5])

        verify(code: copiedCode)
    }

    @IBAction private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    private func verify(code: String) {
        showErrorLabel(nil)
        MBProgressHUD.showAdded(to: view, animated: true)

        switch mode {
        case .otp(let mfaKey):
            SLClient.shared.verifyMfa(key: mfaKey,
                                      token: code,
                                      deviceName: UIDevice.current.name) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    MBProgressHUD.hide(for: self.view, animated: true)

                    switch result {
                    case .success(let apiKey):
                        self.dismiss(animated: true) {
                            self.otpVerificationSuccesful?(apiKey)
                        }

                    case .failure(let error):
                        self.showErrorLabel(error.description)
                        self.reset()
                    }
                }
            }

        case .accountActivation(let email, _):
            SLClient.shared.activate(email: email, code: code) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    MBProgressHUD.hide(for: self.view, animated: true)

                    switch result {
                    case .success:
                        self.dismiss(animated: true) {
                            self.accountVerificationSuccesful?()
                        }

                    case .failure(let error):
                        switch error {
                        // TODO: unreachable case
                        case .reactivationNeeded: self.showReactivateAlert(email: email)
                        default: self.showErrorLabel(error.description)
                        }
                        self.reset()
                    }
                }
            }

        default: return
        }
    }

    private func showErrorLabel(_ errorMessage: String?) {
        if let errorMessage = errorMessage {
            errorLabel.text = errorMessage
            errorLabel.alpha = 1
            errorLabel.shake()
        } else {
            if errorLabel.alpha == 0 { return }
            UIView.animate(withDuration: 0.35) { [unowned self] in
                self.errorLabel.alpha = 0
            }
        }
    }

    private func showReactivateAlert(email: String) {
        let alert = UIAlertController(
            title: "Wrong code too many times",
            message: "We will send you a new activation code for \"\(email)\"",
            preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Ok", style: .default) { [unowned self] _ in
            self.reactivate(email: email)
        }
        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }

    private func reactivate(email: String) {
        MBProgressHUD.showAdded(to: view, animated: true)

        SLClient.shared.reactivate(email: email) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                MBProgressHUD.hide(for: self.view, animated: true)

                switch result {
                case .success:
                    Toast.displayLongly(message: "Check your inbox for new activation code")

                case .failure(let error):
                    self.showErrorLabel(error.description)
                }
            }
        }
    }
}

// MARK: - Button actions
extension VerificationViewController {
    private func addNumber(_ number: String) {
        for numberLabel in numberLabels {
            guard numberLabel.text == numberPlaceholder else { continue }
            numberLabel.text = number
            switch numberLabel {
            case firstNumberLabel:
                showErrorLabel(nil)
            case sixthNumberLabel:
                let code = numberLabels.compactMap { $0.text }.reduce(into: "") { $0 += $1 }
                verify(code: code)
            default: break
            }
            return
        }
    }

    private func deleteLastNumber() {
        if let lastEnteredNumberLabel = numberLabels.last(where: { $0.text != numberPlaceholder }) {
            lastEnteredNumberLabel.text = numberPlaceholder
        }
    }

    private func reset() { numberLabels.forEach { $0.text = numberPlaceholder } }

    @IBAction private func deleteButtonTapped() { deleteLastNumber() }

    @IBAction private func zeroButtonTapped() { addNumber("0") }

    @IBAction private func oneButtonTapped() { addNumber("1") }

    @IBAction private func twoButtonTapped() { addNumber("2") }

    @IBAction private func threeButtonTapped() { addNumber("3") }

    @IBAction private func fourButtonTapped() { addNumber("4") }

    @IBAction private func fiveButtonTapped() { addNumber("5") }

    @IBAction private func sixButtonTapped() { addNumber("6") }

    @IBAction private func sevenButtonTapped() { addNumber("7") }

    @IBAction private func eightButtonTapped() { addNumber("8") }

    @IBAction private func nineButtonTapped() { addNumber("9") }
}
