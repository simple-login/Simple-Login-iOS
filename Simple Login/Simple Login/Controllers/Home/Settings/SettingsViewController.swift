//
//  SettingsViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Toaster

final class SettingsViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    deinit {
        print("SettingsViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
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
        ExportDataTableViewCell.register(with: tableView)
        DeleteAccountTableViewCell.register(with: tableView)
    }
}

// MARK: - Modify
extension SettingsViewController {
    private func showAlertModifyProfile() {
        let alert = UIAlertController(title: "Modify profile", message: nil, preferredStyle: .actionSheet)
        
        let profileAction = UIAlertAction(title: "Modify profile photo", style: .default) { [unowned self] (_) in
            self.showAlertModifyProfilePhoto()
        }
        alert.addAction(profileAction)
        
        let usernameAction = UIAlertAction(title: "Modify display name", style: .default) { [unowned self] (_) in
            self.showAlertModifyUsername()
        }
        alert.addAction(usernameAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showAlertModifyProfilePhoto() {
        let alert = UIAlertController(title: "Modify profile photo", message: nil, preferredStyle: .actionSheet)
        
        let uploadAction = UIAlertAction(title: "Upload new photo", style: .default) { [unowned self] (_) in
            self.showPickPhoto()
        }
        alert.addAction(uploadAction)
        
        let removeAction = UIAlertAction(title: "Remove profile photo", style: .default) { [unowned self] (_) in
            self.removeProfilePhoto()
        }
        alert.addAction(removeAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showAlertModifyUsername() {
        let alert = UIAlertController(title: "Enter new display name", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] (_) in
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
        
        let yesAction = UIAlertAction(title: "Yes, send me email", style: .default) { [unowned self] (_) in
            
        }
        alert.addAction(yesAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showAlertExportData() {
        let alert = UIAlertController(title: "Export data?", message: "We will send you a JSON file containing all your informations", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes, send me", style: .default) { [unowned self] (_) in
            
        }
        alert.addAction(yesAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showAlertDeleteAccount() {
        let alert = UIAlertController(title: "Permanently delete this account", message: "All the informations related to this account will also be deleted. This operation is irreversible. Please confirm your choice.", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Delete everything", style: .destructive) { [unowned self] (_) in
            
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = ProfileAndMembershipTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didTapModifyLabel = { [unowned self] in
                self.showAlertModifyProfile()
            }
            
            cell.didTapUpgradeDowngradeLabel = { [unowned self] in
                Toast.displayShortly(message: "upgrade/downgrade")
            }
            
            return cell
            
        case 1:
            let cell = MfaTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didTapEnableDisableLabel = { [unowned self] in
                Toast.displayShortly(message: "enable/disable MFA")
            }
            
            return cell
            
        case 2:
            let cell = ChangePasswordTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didTapRootView = { [unowned self] in
                self.showAlertChangePassword()
            }
            
            return cell
            
        case 3:
            let cell = NotificationTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didSwitch = { [unowned self] isOn in
               Toast.displayShortly(message: "\(isOn)")
            }
            
            return cell
            
        case 4:
            let cell = ExportDataTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didTapRootView = { [unowned self] in
                self.showAlertExportData()
            }
            
            return cell
            
        case 5:
            let cell = DeleteAccountTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            cell.didTapDeleteLabel = { [unowned self] in
                self.showAlertDeleteAccount()
            }
            
            return cell
            
        default: return UITableViewCell()
        }
    }
}
