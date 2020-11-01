//
//  CreateAliasViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 12/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import MBProgressHUD
import Toaster
import UIKit

final class CreateAliasViewController: BaseApiKeyViewController {
    @IBOutlet private weak var rootStackView: UIStackView!
    @IBOutlet private weak var prefixTextField: UITextField!
    @IBOutlet private weak var suffixView: UIView!
    @IBOutlet private weak var suffixLabel: UILabel!
    @IBOutlet private weak var mailboxesLabel: UILabel!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var noteTextField: UITextField!
    @IBOutlet private weak var hintLabel: UILabel!
    @IBOutlet private weak var warningLabel: UILabel!
    @IBOutlet private weak var createButton: UIButton!

    @IBOutlet private var mailboxRelatedLabels: [UILabel]!

    private var isValidEmailPrefix: Bool = false {
        didSet {
            createButton.isEnabled = isValidEmailPrefix
            createButton.alpha = isValidEmailPrefix ? 1 : 0.3
            prefixTextField.textColor = isValidEmailPrefix ? SLColor.textColor : SLColor.negativeColor
        }
    }

    private var userOptions: UserOptions? {
        didSet {
            suffixLabel.text = userOptions?.suffixes[0].value[0]
            alertUpgradeIfApplicable()
        }
    }

    private var selectedSuffixIndex = 0 {
        didSet {
            suffixLabel.text = userOptions?.suffixes[selectedSuffixIndex].value[0]
        }
    }

    private var selectedMailboxes: [AliasMailbox] = [] {
        didSet {
            mailboxesLabel.attributedText = selectedMailboxes.toAttributedString(fontSize: 14)
        }
    }

    private var mailboxes: [Mailbox] = [] {
        didSet {
            mailboxes.forEach { mailbox in
                if mailbox.isDefault {
                    selectedMailboxes = [mailbox.toAliasMailbox()]
                }
            }
        }
    }

    var showPremiumFeatures: (() -> Void)?
    var createdAlias: ((_ alias: Alias) -> Void)?
    var didDisappear: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        prefixTextField.becomeFirstResponder()
        isValidEmailPrefix = false
        setUpUI()
        fetchUserOptionsAndMailboxes()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didDisappear?()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Hide keyboard on background tap
        view.endEditing(true)
    }

    private func setUpUI() {
        prefixTextField.textColor = SLColor.textColor
        prefixTextField.delegate = self

        // suffixView
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentSuffixListViewController))
        suffixView.isUserInteractionEnabled = true
        suffixView.addGestureRecognizer(tap)

        warningLabel.textColor = SLColor.negativeColor

        // Mailbox related labels
        mailboxRelatedLabels.forEach { label in
            let tap = UITapGestureRecognizer(target: self, action: #selector(presentSelectMailboxesViewController))
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(tap)
        }
        mailboxesLabel.text = nil

        createButton.setTitleColor(SLColor.tintColor, for: .normal)

        hintLabel.textColor = SLColor.secondaryTitleColor
    }

    private func fetchUserOptionsAndMailboxes() {
        MBProgressHUD.showAdded(to: view, animated: true)
        rootStackView.isHidden = true

        let fetchGroup = DispatchGroup()
        var storedError: SLError?
        var fetchedMailboxes: [Mailbox]?
        var fetchedUserOptions: UserOptions?

        fetchGroup.enter()
        SLClient.shared.fetchMailboxes(apiKey: apiKey) { result in
            switch result {
            case .success(let mailboxArray): fetchedMailboxes = mailboxArray.mailboxes
            case .failure(let error): storedError = error
            }

            fetchGroup.leave()
        }

        fetchGroup.enter()
        SLApiService.shared.fetchUserOptions(apiKey: apiKey) { result in
            switch result {
            case .success(let userOptions): fetchedUserOptions = userOptions
            case .failure(let error): storedError = error
            }

            fetchGroup.leave()
        }

        fetchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)

            if let error = storedError {
                self.dismiss(animated: true) {
                    Toast.displayError(error)
                }
            } else if let fetchedUserOptions = fetchedUserOptions, let fetchedMailboxes = fetchedMailboxes {
                self.rootStackView.isHidden = false
                self.userOptions = fetchedUserOptions
                self.mailboxes = fetchedMailboxes
            }
        }
    }

    private func createAlias() {
        guard let suffix = userOptions?.suffixes[selectedSuffixIndex] else {
            Toast.displayShortly(message: "No suffix is selected")
            return
        }

        MBProgressHUD.showAdded(to: view, animated: true)

        let name = nameTextField.text != "" ? nameTextField.text : nil
        let note = noteTextField.text != "" ? noteTextField.text : nil
        let mailboxIds = selectedMailboxes.map { $0.id }

        SLApiService.shared.createAlias(apiKey: apiKey,
                                        prefix: prefixTextField.text ?? "",
                                        suffix: suffix,
                                        mailboxIds: mailboxIds,
                                        name: name,
                                        note: note) { [weak self] result in
            guard let self = self else { return }

            MBProgressHUD.hide(for: self.view, animated: true)

            switch result {
            case .success(let newlyCreatedAlias):
                self.createdAlias?(newlyCreatedAlias)
                self.dismiss(animated: true, completion: nil)

            case .failure(let error):
                self.dismiss(animated: true) {
                    Toast.displayError(error)
                }
            }
        }
    }

    @IBAction private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func createButtonTapped() {
        createAlias()
    }

    @IBAction private func prefixTextFieldEditingChanged() {
        guard let text = prefixTextField.text else { return }
        isValidEmailPrefix = text.isValidEmailPrefix()
    }

    @objc
    private func presentSuffixListViewController() {
        performSegue(withIdentifier: "showSuffixes", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let suffixListViewController as SuffixListViewController:
            suffixListViewController.selectedSuffixIndex = selectedSuffixIndex
            suffixListViewController.suffixes = userOptions?.suffixes
            suffixListViewController.delegate = self

        default: return
        }
    }

    private func alertUpgradeIfApplicable() {
        guard let userOptions = userOptions, !userOptions.canCreate else { return }

        let alert = UIAlertController(
            title: "Upgrade needed",
            // swiftlint:disable:next line_length
            message: "You have reached the limit. Please upgrade to premium for unlimited aliases and more useful features.",
            preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Show me premium features", style: .default) { [unowned self] _ in
            self.dismiss(animated: true) {
                self.showPremiumFeatures?()
            }
        }
        alert.addAction(okAction)

        let cancelAction = UIAlertAction(title: "Not right now", style: .cancel) { [unowned self] _ in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    @objc
    private func presentSelectMailboxesViewController() {
        let selectMailboxesViewController = SelectMailboxesViewController.instantiate(storyboardName: "Mailbox")
        selectMailboxesViewController.selectedIds = selectedMailboxes.map { $0.id }

        selectMailboxesViewController.didSelectMailboxes = { [unowned self] selectedMailboxes in
            self.selectedMailboxes = selectedMailboxes
        }

        present(selectMailboxesViewController, animated: true, completion: nil)
    }
}

// MARK: - SuffixListViewControllerDelegate
extension CreateAliasViewController: SuffixListViewControllerDelegate {
    func didSelectSuffix(atIndex index: Int) {
        selectedSuffixIndex = index
    }
}

// MARK: - UITextFieldDelegate
extension CreateAliasViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createAlias()
        return true
    }
}
