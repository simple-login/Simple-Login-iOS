//
//  ContactViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import MBProgressHUD
import MessageUI
import Toaster
import UIKit

final class ContactViewController: BaseApiKeyViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()

    var alias: Alias!

    private var contacts: [Contact] = []

    private var noContact = false {
        didSet {
            tableView.isHidden = noContact
        }
    }

    private var fetchedPage = -1
    private var isFetching = false
    private var moreToLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        fetchContacts()
    }

    private func setUpUI() {
        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.tableFooterView = UIView(frame: .zero)

        ContactTableViewCell.register(with: tableView)
        tableView.register(
            UINib(nibName: "ContactTableHeaderView", bundle: nil),
            forHeaderFooterViewReuseIdentifier: "ContactTableHeaderView")
        tableView.register(
            UINib(nibName: "LoadingFooterView", bundle: nil),
            forHeaderFooterViewReuseIdentifier: "LoadingFooterView")

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    @objc
    private func refresh() {
        fetchContacts()
    }

    private func fetchContacts() {
        if refreshControl.isRefreshing {
            moreToLoad = true
        }

        guard moreToLoad, !isFetching else { return }

        isFetching = true

        let pageToFetch = refreshControl.isRefreshing ? 0 : fetchedPage + 1

        SLClient.shared.fetchContacts(apiKey: apiKey, aliasId: alias.id, page: pageToFetch) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.isFetching = false

                switch result {
                case .success(let contactArray):
                    if contactArray.contacts.isEmpty {
                        self.moreToLoad = false
                    } else {
                        if self.refreshControl.isRefreshing {
                            self.fetchedPage = 0
                            self.contacts.removeAll()
                        } else {
                            self.fetchedPage += 1
                        }

                        self.contacts.append(contentsOf: contactArray.contacts)
                    }

                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                        Toast.displayUpToDate()
                    }

                    self.noContact = self.contacts.isEmpty
                    self.tableView.reloadData()

                case .failure(let error):
                    self.refreshControl.endRefreshing()
                    Toast.displayError(error)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let createContactViewController as CreateContactViewController:
            Vibration.rigid.vibrate()
            createContactViewController.alias = alias
            createContactViewController.didCreateContact = { [unowned self] in
                self.refreshControl.beginRefreshing()
                self.refresh()
            }
        default: return
        }
    }

    private func presentAlertConfirmDeleteContact(at indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        let alert = UIAlertController(
            title: "Delete \"\(contact.email)\"?",
            message: "🛑 This operation is irreversible. Please confirm.",
            preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
            self.delete(contact: contact, indexPath: indexPath)
        }
        alert.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func delete(contact: Contact, indexPath: IndexPath) {
        MBProgressHUD.showAdded(to: view, animated: true)

        SLClient.shared.deleteContact(apiKey: apiKey, contactId: contact.id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                MBProgressHUD.hide(for: self.view, animated: true)

                switch result {
                case .success:
                    self.tableView.performBatchUpdates({
                        self.contacts.removeAll { $0.id == contact.id }
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }, completion: { _ in
                        self.tableView.reloadData()
                        Toast.displayShortly(message: "Deleted contact \"\(contact.email)\"")
                    })

                case .failure(let error): Toast.displayError(error)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension ContactViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contact = contacts[indexPath.row]
        presentReverseAliasAlert(from: alias.email,
                                 to: contact.email,
                                 reverseAlias: contact.reverseAlias,
                                 reverseAliasAddress: contact.reverseAliasAddress)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // swiftlint:disable:next line_length
        let contactTableHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ContactTableHeaderView") as? ContactTableHeaderView
        contactTableHeaderView?.bind(with: alias.email)
        return contactTableHeaderView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        moreToLoad ? 44.0 : 1.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if moreToLoad {
            // swiftlint:disable:next line_length
            let loadingFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "LoadingFooterView") as? LoadingFooterView
            loadingFooterView?.animate()
            return loadingFooterView
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if moreToLoad {
            fetchContacts()
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction =
            UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] _, indexPath in
                Vibration.warning.vibrate()
                self.presentAlertConfirmDeleteContact(at: indexPath)
            }

        return [deleteAction]
    }
}

// MARK: - UITableViewDataSource
extension ContactViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ContactTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.bind(with: contacts[indexPath.row])
        return cell
    }
}
