//
//  MailboxViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 28/05/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import MBProgressHUD
import Toaster
import UIKit

final class MailboxViewController: BaseApiKeyLeftMenuButtonViewController, Storyboarded {
    @IBOutlet private weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()

    private var mailboxes: [Mailbox] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        fetchMailboxes()
    }

    private func setUpUI() {
        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.tableFooterView = UIView(frame: .zero)

        MailboxTableViewCell.register(with: tableView)

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchMailboxes), for: .valueChanged)
    }

    @objc
    private func fetchMailboxes() {
        SLClient.shared.fetchMailboxes(apiKey: apiKey) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let mailboxArray):
                    self.mailboxes = mailboxArray.mailboxes
                    self.tableView.reloadData()

                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                        Toast.displayUpToDate()
                    }

                case .failure(let error):
                    self.refreshControl.endRefreshing()
                    Toast.displayError(error)
                }
            }
        }
    }

    @IBAction private func alertCreateMailbox() {
        let alert = UIAlertController(
            title: "New mailbox",
            message: "A verification email will be sent to this email address",
            preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "my-another-email@example.com"
            textField.keyboardType = .emailAddress
        }

        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            if let email = alert.textFields?[0].text {
                self.createMailbox(email)
            }
        }
        alert.addAction(createAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func createMailbox(_ email: String) {
        MBProgressHUD.showAdded(to: view, animated: true)

        SLApiService.shared.createMailbox(apikey: apiKey, email: email) { [weak self] result in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)

            switch result {
            case .success:
                Toast.displayLongly(message: "You are going to receive a confirmation email for \"\(email)\"")
            case .failure(let error): Toast.displayError(error)
            }
        }
    }
}

// MARK: - Make default mailbox
extension MailboxViewController {
    private func presentMakeDefaultConfirmationAlert(_ mailbox: Mailbox) {
        let alert = UIAlertController(
            title: "Please confirm",
            message: "Make \"\(mailbox.email)\" default mailbox?",
            preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [unowned self] _ in
            self.makeDefault(mailboxId: mailbox.id)
        }
        alert.addAction(confirmAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func makeDefault(mailboxId: Int) {
        MBProgressHUD.showAdded(to: view, animated: true)

        SLApiService.shared.makeDefaultMailbox(apikey: apiKey, id: mailboxId) { [weak self] result in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)

            switch result {
            case .success:
                self.mailboxes.forEach { mailbox in
                    if mailbox.id == mailboxId {
                        mailbox.setIsDefault(true)
                    } else if mailbox.isDefault {
                        mailbox.setIsDefault(false)
                    }
                }

                self.tableView.reloadData()

            case .failure(let error):
                Toast.displayError(error)
            }
        }
    }
}

// MARK: - Delete mailbox
extension MailboxViewController {
    private func presentDeleteConfirmationAlert(_ mailbox: Mailbox, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete \"\(mailbox.email)\"",
            // swiftlint:disable:next line_length
            message: "🛑 All aliases associated with this mailbox will also be deleted. This operation is irreversible. Please confirm.",
            preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
            self.delete(mailbox: mailbox, at: indexPath)
        }
        alert.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func delete(mailbox: Mailbox, at indexPath: IndexPath) {
        MBProgressHUD.showAdded(to: view, animated: true)

        SLApiService.shared.deleteMailbox(apiKey: apiKey, id: mailbox.id) { [weak self] result in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)

            switch result {
            case .success:
                self.tableView.performBatchUpdates({
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.mailboxes.removeAll(where: { $0.id == mailbox.id })
                }, completion: { _ in
                    Toast.displayShortly(message: "Deleted \"\(mailbox.email)\"")
                })

            case .failure(let error):
                Toast.displayError(error)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension MailboxViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let mailbox = mailboxes[indexPath.row]
        guard !mailbox.isDefault else { return nil }

        let deleteAction =
            UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] _, indexPath in
            self.presentDeleteConfirmationAlert(mailbox, at: indexPath)
        }

        let setAsDefaultAction =
            UITableViewRowAction(style: .normal, title: "Set as default") { [unowned self] _, _ in
            self.presentMakeDefaultConfirmationAlert(mailbox)
        }

        return [deleteAction, setAsDefaultAction]
    }
}

// MARK: - UITableViewDataSource
extension MailboxViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mailboxes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MailboxTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let mailbox = mailboxes[indexPath.row]
        cell.bind(with: mailbox)
        return cell
    }
}
