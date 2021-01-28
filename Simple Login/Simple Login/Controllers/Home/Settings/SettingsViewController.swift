//
//  SettingsViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import LocalAuthentication
import MBProgressHUD
import Photos
import Toaster
import UIKit

extension LABiometryType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none: return "Biometric authentication not supported"
        case .touchID: return "Touch ID"
        case .faceID: return "Face ID"
        @unknown default: return "Unknown biometric type"
        }
    }
}

final class SettingsViewController: BaseApiKeyLeftMenuButtonViewController, Storyboarded {
    @IBOutlet private weak var tableView: UITableView!

    private enum Section {
        case profileAndMembership
        case biometricAuthentication
        case notification
        case randomAlias
        case senderFormat
    }

    var didUpdateUserInfo: ((_ userInfo: UserInfo) -> Void)?

    var userInfo: UserInfo!
    private var userSettings: UserSettings!
    private var domains: [DomainLite]!
    private var sections: [Section] = []
    private var biometryType = LABiometryType.none

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(userInfo != nil, "UserInfo must be set for \(Self.self)")
        setUpUI()
        initSections()
        fetchUserSettingsAndDomains()
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

        BiometricAuthTableViewCell.register(with: tableView)
        ChangePasswordTableViewCell.register(with: tableView)
        DeleteAccountTableViewCell.register(with: tableView)
        ExportDataTableViewCell.register(with: tableView)
        ListDeletedAliasesTableViewCell.register(with: tableView)
        MfaTableViewCell.register(with: tableView)
        NotificationTableViewCell.register(with: tableView)
        ProfileAndMembershipTableViewCell.register(with: tableView)
        RandomAliasTableViewCell.register(with: tableView)
        SenderFormatTableViewCell.register(with: tableView)
    }

    private func initSections() {
        let localAuthenticationContext = LAContext()
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            biometryType = localAuthenticationContext.biometryType
        }

        sections = [.profileAndMembership, .notification, .randomAlias, .senderFormat]

        if biometryType != .none {
            sections.insert(.biometricAuthentication, at: 1)
        }
    }

    private func fetchUserSettingsAndDomains() {
        guard let apiKey = SLKeychainService.getApiKey() else { return }
        MBProgressHUD.showAdded(to: view, animated: true)

        let fetchGroup = DispatchGroup()
        var storedUserSettings: UserSettings?
        var storedDomains: [DomainLite]?
        var storedError: SLError?

        fetchGroup.enter()
        SLClient.shared.fetchUserSettings(apiKey: apiKey) { result in
            switch result {
            case .success(let userSettings): storedUserSettings = userSettings
            case .failure(let error): storedError = error
            }
            fetchGroup.leave()
        }

        fetchGroup.enter()
        SLClient.shared.getDomainLites(apiKey: apiKey) { result in
            switch result {
            case .success(let domains): storedDomains = domains
            case .failure(let error): storedError = error
            }
            fetchGroup.leave()
        }

        fetchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)

            if let error = storedError {
                self.alertRetry(error)
            } else if let userSettings = storedUserSettings, let domains = storedDomains {
                self.userSettings = userSettings
                self.domains = domains
                self.tableView.reloadData()
            }
        }
    }

    private func updateUserSettings(option: UserSettings.Option) {
        guard let apiKey = SLKeychainService.getApiKey() else { return }
        MBProgressHUD.showAdded(to: view, animated: true)
        SLClient.shared.updateUserSettings(apiKey: apiKey, option: option) { [weak self] result in
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

    private func updateName(_ name: String?) {
        guard let apiKey = SLKeychainService.getApiKey() else { return }
        MBProgressHUD.showAdded(to: view, animated: true)
        SLClient.shared.updateName(apiKey: apiKey, name: name) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                switch result {
                case .success(let userInfo):
                    self.didUpdateUserInfo?(userInfo)
                    self.userInfo = userInfo
                    self.tableView.reloadData()
                case .failure(let error): Toast.displayError(error)
                }
            }
        }
    }

    private func updateProfilePicture(_ base64String: String?) {
        guard let apiKey = SLKeychainService.getApiKey() else { return }
        MBProgressHUD.showAdded(to: view, animated: true)
        SLClient.shared.updateProfilePicture(apiKey: apiKey,
                                             base64String: base64String) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                switch result {
                case .success(let userInfo):
                    self.didUpdateUserInfo?(userInfo)
                    self.userInfo = userInfo
                    self.tableView.reloadData()
                case .failure(let error): Toast.displayError(error)
                }
            }
        }
    }

    private func alertRetry(_ error: SLError) {
        let alert = UIAlertController(title: "Error occured", message: error.description, preferredStyle: .alert)

        let retryAction = UIAlertAction(title: "Retry", style: .default) { [unowned self] _ in
            self.fetchUserSettingsAndDomains()
        }
        alert.addAction(retryAction)

        present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let domainLiteListViewController as DomainLiteListViewController:
            domainLiteListViewController.domains = domains
            domainLiteListViewController.currentDefaultDomainName = userSettings.randomAliasDefaultDomain
            domainLiteListViewController.didSelectDomain = { [unowned self] domain in
                self.updateUserSettings(option: .randomAliasDefaultDomain(domain.name))
            }

        default: break
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
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized: self.showPhotoPicker()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { newStatus in
                    if newStatus == .authorized {
                        DispatchQueue.main.async {
                            self.showPhotoPicker()
                        }
                    }
                }
            default: self.alertOpenSettings()
            }
        }
        alert.addAction(uploadAction)

        let removeAction = UIAlertAction(title: "Remove profile photo", style: .destructive) { [unowned self] _ in
            self.updateProfilePicture(nil)
        }
        alert.addAction(removeAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func showAlertModifyUsername() {
        let alert = UIAlertController(title: "Enter new display name", message: nil, preferredStyle: .alert)

        alert.addTextField()

        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            self.updateName(alert.textFields?[0].text)
        }
        alert.addAction(saveAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func showAlertModifyRandomMode() {
        let style: UIAlertController.Style =
            UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet

        let alert = UIAlertController(title: nil,
                                      message: "Change the way random aliases are generated by default",
                                      preferredStyle: style)

        let randomWordsAction =
            UIAlertAction(title: RandomMode.word.description, style: .default) { [unowned self] _ in
                self.updateUserSettings(option: .randomMode(.word))
            }
        alert.addAction(randomWordsAction)

        let uuidAction = UIAlertAction(title: RandomMode.uuid.description, style: .default) { [unowned self] _ in
            self.updateUserSettings(option: .randomMode(.uuid))
        }
        alert.addAction(uuidAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func showAlertModifySenderFormat() {
        let style: UIAlertController.Style =
            UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet

        let alert = UIAlertController(title: "Choose sender address format",
                                      // swiftlint:disable:next line_length
                                      message: "John Doe who uses john.doe@example.com to send you an email, how would you like to format his email?",
                                      preferredStyle: style)

        for senderFormat in SenderFormat.allCases {
            let senderFormatAction =
                UIAlertAction(title: senderFormat.description, style: .default) { [unowned self] _ in
                    self.updateUserSettings(option: .senderFormat(senderFormat))
                }
            alert.addAction(senderFormatAction)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func alertOpenSettings() {
        let alert = UIAlertController(title: nil,
                                      message: "Please allow access to photo library",
                                      preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
            }
        }
        alert.addAction(settingsAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func showPhotoPicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
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
            return sections.count
        }

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .profileAndMembership: return profileAndMembershipTableViewCell(for: indexPath)
        case .biometricAuthentication: return biometricAuthTableViewCell(for: indexPath)
        case .notification: return notificationTableViewCell(for: indexPath)
        case .randomAlias: return randomAliasTableViewCell(for: indexPath)
        case .senderFormat: return senderFormatTableViewCell(for: indexPath)
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

    private func biometricAuthTableViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = BiometricAuthTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

        cell.didSwitch = { [unowned self] isOn in
            let localAuthenticationContext = LAContext()
            localAuthenticationContext.localizedFallbackTitle = "Or use your passcode"
            let action = isOn ? "activate" : "deactivate"
            let reason = "Please authenticate to \(action) \(self.biometryType.description) authentication"
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication,
                                                      localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        if isOn {
                            UserDefaults.activateBiometricAuth()
                            Toast.displayShortly(message: "\(self.biometryType.description) deactivated")
                        } else {
                            UserDefaults.deactivateBiometricAuth()
                            Toast.displayShortly(message: "\(self.biometryType.description) activated")
                        }
                    } else if let error = error {
                        Toast.displayShortly(message: error.localizedDescription)
                        cell.setSwitch(isOn: !isOn)
                    }
                }
            }
        }

        cell.bind(text: biometryType.description + " authentication")

        return cell
    }

    private func notificationTableViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = NotificationTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

        cell.didSwitch = { [unowned self] isOn in
            let option = UserSettings.Option.notification(isOn)
            self.updateUserSettings(option: option)
        }

        cell.bind(userSettings: userSettings)

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

    private func randomAliasTableViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = RandomAliasTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

        cell.didTapRandomModeButton = { [unowned self] in
            self.showAlertModifyRandomMode()
        }

        cell.didTapDefaultDomainButton = { [unowned self] in
            self.performSegue(withIdentifier: "showDomains", sender: nil)
        }

        cell.bind(userSettings: userSettings)

        return cell
    }

    private func senderFormatTableViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = SenderFormatTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

        cell.didTapSenderFormatButton = { [unowned self] in
            self.showAlertModifySenderFormat()
        }

        cell.bind(userSettings: userSettings)

        return cell
    }
}

// MARK: - UIImagePickerControllerDelegate
extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[.originalImage] as? UIImage,
           let base64String = pickedImage.jpegData(compressionQuality: 0.5)?.base64EncodedString() {
            updateProfilePicture(base64String)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
