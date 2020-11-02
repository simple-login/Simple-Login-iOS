//
//  AliasSearchViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 15/03/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import MBProgressHUD
import Toaster
import UIKit

final class AliasSearchViewController: BaseApiKeyViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var messageLabel: UILabel!

    private var aliases: [Alias] = []

    private var searchTerm: String?
    private var fetchedPage: Int = -1
    private var isFetching: Bool = false
    private var moreToLoad: Bool = true

    private var noAlias: Bool = false {
        didSet {
            tableView.isHidden = noAlias
        }
    }

    var toggledAlias: ((_ alias: Alias) -> Void)?
    var deletedAlias: ((_ alias: Alias) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
        // Add search bar
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Enter search term"
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        navigationItem.titleView = searchBar

        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear

        AliasTableViewCell.register(with: tableView)
    }

    @IBAction private func closeButtonTapped() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    private func search(_ term: String? = nil) {
        if let term = term {
            self.searchTerm = term
            messageLabel.text = "No result found for \"\(term)\""
            moreToLoad = true
            isFetching = false
            fetchedPage = -1
            aliases.removeAll()
        }

        guard moreToLoad, !isFetching else { return }

        MBProgressHUD.showAdded(to: view, animated: true)
        isFetching = true

        SLClient.shared.fetchAliases(apiKey: apiKey, page: fetchedPage + 1, searchTerm: self.searchTerm ?? "") { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                MBProgressHUD.hide(for: self.view, animated: true)
                self.isFetching = false

                switch result {
                case .success(let aliasArray):
                    if aliasArray.aliases.isEmpty {
                        self.moreToLoad = false
                    } else {
                        self.fetchedPage += 1
                        self.aliases.append(contentsOf: aliasArray.aliases)
                    }

                    self.noAlias = self.aliases.isEmpty
                    self.tableView.reloadData()

                case .failure(let error):
                    Toast.displayError(error)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let sendEmailViewController as ContactViewController:
            guard let alias = sender as? Alias else { return }
            sendEmailViewController.alias = alias

        case let aliasActivityViewController as AliasActivityViewController:
            guard let alias = sender as? Alias else { return }
            aliasActivityViewController.alias = alias

        default: return
        }
    }
}

// MARK: - Actions
extension AliasSearchViewController {
    private func toggle(alias: Alias) {
        MBProgressHUD.showAdded(to: view, animated: true)

        SLClient.shared.toggleAlias(apiKey: apiKey, aliasId: alias.id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                MBProgressHUD.hide(for: self.view, animated: true)

                switch result {
                case .success(let enabled):
                    alias.setEnabled(enabled.value)
                    self.toggledAlias?(alias)

                case .failure(let error):
                    Toast.displayError(error)
                }

                self.tableView.reloadData()
            }
        }
    }

    private func presentAlertConfirmDelete(alias: Alias, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete \(alias.email)",
            // swiftlint:disable:next line_length
            message: "🛑 People/apps who used to contact you via this alias cannot reach you any more. This operation is irreversible",
            preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
            self.delete(alias: alias, at: indexPath)
        }
        alert.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func delete(alias: Alias, at indexPath: IndexPath) {
        MBProgressHUD.showAdded(to: view, animated: true)

        SLApiService.shared.deleteAlias(apiKey: apiKey, id: alias.id) { [weak self] result in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)

            switch result {
            case .success:
                self.tableView.performBatchUpdates({
                    self.aliases.removeAll(where: { $0 == alias })
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }, completion: { _ in
                    self.tableView.reloadData()
                    self.noAlias = self.aliases.isEmpty
                    self.deletedAlias?(alias)
                    Toast.displayShortly(message: "Deleted alias \"\(alias.email)\"")
                })

            case .failure(let error):
                Toast.displayError(error)
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension AliasSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchTerm = searchBar.text {
            search(searchTerm)
            searchBar.resignFirstResponder()
        }
    }
}

// MARK: - UITableViewDelegate
extension AliasSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showActivities", sender: aliases[indexPath.row])
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == aliases.count - 1) && moreToLoad {
            search()
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let alias = aliases[indexPath.row]

        let deleteAction =
            UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] _, indexPath in
            self.presentAlertConfirmDelete(alias: alias, at: indexPath)
        }

        return [deleteAction]
    }
}

// MARK: - UITableViewDataSource
extension AliasSearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        aliases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AliasTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let alias = aliases[indexPath.row]

        cell.bind(with: alias)

        cell.didToggleStatus = { [unowned self] isEnabled in
            self.toggle(alias: alias)
        }

        cell.didTapCopyButton = {
            UIPasteboard.general.string = alias.email
            Toast.displayShortly(message: "Copied \"\(alias.email)\"")
        }

        cell.didTapSendButton = { [unowned self] in
            self.performSegue(withIdentifier: "showContacts", sender: alias)
        }

        cell.didTapRightArrowButton = { [unowned self] in
            self.performSegue(withIdentifier: "showActivities", sender: alias)
        }

        return cell
    }
}
