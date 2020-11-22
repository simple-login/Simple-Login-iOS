//
//  SettingsViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import MBProgressHUD
import Toaster
import UIKit

final class SettingsViewController: BaseApiKeyLeftMenuButtonViewController, Storyboarded {
    @IBOutlet private weak var tableView: UITableView!

    var userInfo: UserInfo!
    private var userSettings: UserSettings!

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(userInfo != nil, "UserInfo must be set for \(Self.self)")
        setUpUI()
        fetchUserSettings()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Fix error labels display only 1 line
        tableView.reloadSections([0], with: .none)
    }

    private func setUpUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear

        ProfileAndMembershipTableViewCell.register(with: tableView)
        MfaTableViewCell.register(with: tableView)
        ChangePasswordTableViewCell.register(with: tableView)
        NotificationTableViewCell.register(with: tableView)
        ListDeletedAliasesTableViewCell.register(with: tableView)
        ExportDataTableViewCell.register(with: tableView)
        DeleteAccountTableViewCell.register(with: tableView)
    }

    private func fetchUserSettings() {
        guard let apiKey = SLKeychainService.getApiKey() else { return }
        MBProgressHUD.showAdded(to: view, animated: true)
        SLClient.shared.fetchUserSettings(apiKey: apiKey) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                switch result {
                case .success(let userSettings):
                    self.userSettings = userSettings
                    self.tableView.reloadData()
                case .failure(let error): Toast.displayError(error)
                }
            }
        }
    }
}

// MARK: - Modify
extension SettingsViewController {
    private func showAlertModifyProfile() {
        let alert = UIAlertController(title: "Modify profile", message: nil, preferredStyle: .actionSheet)

        let profileAction = UIAlertAction(title: "Modify profile photo", style: .default) { [unowned self] _ in
            self.showAlertModifyProfilePhoto()
        }
        alert.addAction(profileAction)

        let usernameAction = UIAlertAction(title: "Modify display name", style: .default) { [unowned self] _ in
            self.showAlertModifyUsername()
        }
        alert.addAction(usernameAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func showAlertModifyProfilePhoto() {
        let alert = UIAlertController(title: "Modify profile photo", message: nil, preferredStyle: .actionSheet)

        let uploadAction = UIAlertAction(title: "Upload new photo", style: .default) { [unowned self] _ in
            self.showPickPhoto()
        }
        alert.addAction(uploadAction)

        let removeAction = UIAlertAction(title: "Remove profile photo", style: .default) { [unowned self] _ in
            self.removeProfilePhoto()
        }
        alert.addAction(removeAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func showAlertModifyUsername() {
        let alert = UIAlertController(title: "Enter new display name", message: nil, preferredStyle: .alert)

        alert.addTextField { _ in
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            self.saveUsername()
        }
        alert.addAction(saveAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func showPickPhoto() {
        Toast.displayShortly(message: #function)
    }

    private func removeProfilePhoto() {
        Toast.displayShortly(message: #function)
    }

    private func saveUsername() {
        Toast.displayShortly(message: #function)
    }
}

// MARK: - Other actions
extension SettingsViewController {
    private func showAlertChangePassword() {
        let alert = UIAlertController(title: "Change password?", message: nil, preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes, send me email", style: .default) { _ in
        }
        alert.addAction(yesAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func showAlertExportData() {
        let alert = UIAlertController(
            title: "Export data?",
            message: "We will send you a JSON file containing all your informations",
            preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes, send me", style: .default) { _ in
        }
        alert.addAction(yesAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func showAlertDeleteAccount() {
        let alert = UIAlertController(
            title: "Permanently delete this account",
            // swiftlint:disable:next line_length
            message: "All the informations related to this account will also be deleted. This operation is irreversible. Please confirm your choice.",
            preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Delete everything", style: .destructive) { _ in
        }
        alert.addAction(yesAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if userSettings != nil {
            return 2
        }

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return profileAndMembershipTableViewCell(for: indexPath)
        case 1: return notificationTableViewCell(for: indexPath)
        default: return UITableViewCell()
        }
    }
}

// MARK: - Cells
extension SettingsViewController {
    private func profileAndMembershipTableViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = ProfileAndMembershipTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

        cell.bind(with: userInfo)

        cell.didTapModifyLabel = { [unowned self] in
            self.showAlertModifyProfile()
        }

        cell.didTapUpgradeLabel = { [unowned self] in
            self.performSegue(withIdentifier: "showIAP", sender: nil)
        }

        return cell
    }

    private func mfaTableViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = MfaTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

        cell.didTapEnableDisableLabel = {
            Toast.displayShortly(message: "enable/disable MFA")
        }

        return cell
    }

    private func changePasswordTableViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = ChangePasswordTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

        cell.didTapRootView = { [unowned self] in
            self.showAlertChangePassword()
        }

        return cell
    }

    private func notificationTableViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = NotificationTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

        cell.didSwitch = { isOn in

        }

        return cell
    }

    private func listDeletedAliasesTableViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = ListDeletedAliasesTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

        cell.didTapRootView = { [unowned self] in
            self.performSegue(withIdentifier: "showDeletedAliases", sender: nil)
        }

        return cell
    }

    private func exportDataTableViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = ExportDataTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

        cell.didTapRootView = { [unowned self] in
            self.showAlertExportData()
        }

        return cell
    }

    private func deleteAccountTableViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = DeleteAccountTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

        cell.didTapDeleteLabel = { [unowned self] in
            self.showAlertDeleteAccount()
        }

        return cell
    }
}
