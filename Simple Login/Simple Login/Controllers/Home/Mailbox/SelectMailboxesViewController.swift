//
//  SelectMailboxesViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 01/06/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import MBProgressHUD
#if HOSTAPP
import Toaster
#endif
import UIKit

final class SelectMailboxesViewController: BaseApiKeyViewController, Storyboarded {
    @IBOutlet private weak var tableView: UITableView!

    var didSelectMailboxes: ((_ mailboxes: [AliasMailbox]) -> Void)?

    private var mailboxes: [Mailbox] = []

    var selectedIds: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        fetchMailboxes()
    }

    private func setUpUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    @IBAction private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func saveButtonTapped() {
        let selectedMailboxes = mailboxes.filter { selectedIds.contains($0.id) }

        dismiss(animated: true) { [unowned self] in
            self.didSelectMailboxes?(selectedMailboxes.map { $0.toAliasMailbox() })
        }
    }

    private func fetchMailboxes() {
        MBProgressHUD.showAdded(to: view, animated: true)

        SLClient.shared.fetchMailboxes(apiKey: apiKey) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                MBProgressHUD.hide(for: self.view, animated: true)

                switch result {
                case .success(let mailboxArray):
                    self.mailboxes = mailboxArray.mailboxes
                    self.tableView.reloadData()

                case .failure(let error):
                    self.dismiss(animated: true) {
                        self.displayError(error)
                    }
                }
            }
        }
    }

    private func displayError(_ error: SLError) {
        #if HOSTAPP
        Toast.displayError(error)
        #else
        let alert = UIAlertController(title: "Error occured",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alert.addAction(closeAction)
        present(alert, animated: true, completion: nil)
        #endif
    }
}

// MARK: - UITableViewDelegate
extension SelectMailboxesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            // Select all
            selectedIds = mailboxes.map { $0.id }
            tableView.reloadData()
        } else {
            let mailbox = mailboxes[indexPath.row]

            if selectedIds.contains(mailbox.id) {
                // Must select at least 1 mailbox
                if selectedIds.count > 1 {
                    selectedIds.removeAll { $0 == mailbox.id }
                }
            } else {
                selectedIds.append(mailbox.id)
            }

            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - UITableViewDataSource
extension SelectMailboxesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        mailboxes.isEmpty ? 0 : 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }

        return mailboxes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if indexPath.section == 0 {
            cell.textLabel?.text = "[Select all]"
            return cell
        }

        let mailbox = mailboxes[indexPath.row]
        cell.textLabel?.text = mailbox.email

        if selectedIds.contains(mailbox.id) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
}
