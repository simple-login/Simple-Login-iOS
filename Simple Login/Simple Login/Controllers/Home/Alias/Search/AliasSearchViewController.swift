//
//  AliasSearchViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 15/03/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD
import FirebaseAnalytics

final class AliasSearchViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var messageLabel: UILabel!
    
    private var aliases: [Alias] = []
    
    private var searchTerm: String? = nil
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
    
    deinit {
        print("AliasSearchViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        Analytics.logEvent("open_alias_search_view_controller", parameters: nil)
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
        guard let apiKey = SLKeychainService.getApiKey() else {
            Toast.displayErrorRetrieveingApiKey()
            return
        }
        
        if let term = term {
            self.searchTerm = term
            messageLabel.text = "No result found for \"\(term)\""
            moreToLoad = true
            isFetching = false
            fetchedPage = -1
            aliases.removeAll()
            Analytics.logEvent("alias_search_perform_search", parameters: nil)
        }
        
        guard moreToLoad, !isFetching else { return }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        isFetching = true
        
        SLApiService.fetchAliases(apiKey: apiKey, page: fetchedPage + 1, searchTerm: self.searchTerm ?? "") { [weak self] (aliases, error) in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            self.isFetching = false
            
            if let aliases = aliases {
                if aliases.count == 0 {
                    self.moreToLoad = false
                } else {
                    self.fetchedPage += 1
                    self.aliases.append(contentsOf: aliases)
                }
                
                self.noAlias = self.aliases.isEmpty
                self.tableView.reloadData()
                Analytics.logEvent("alias_search_success", parameters: nil)
                
            } else if let error = error {
                Toast.displayError(error)
                Analytics.logEvent("alias_search_error", parameters: error.toParameter())
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
        guard let apiKey = SLKeychainService.getApiKey() else {
            Toast.displayErrorRetrieveingApiKey()
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        SLApiService.toggleAlias(apiKey: apiKey, id: alias.id) { [weak self] (enabled, error) in
            guard let self = self else { return }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let enabled = enabled {
                alias.setEnabled(enabled)
                self.toggledAlias?(alias)
                
                if enabled {
                    Analytics.logEvent("alias_search_enabled_an_alias", parameters: nil)
                } else {
                    Analytics.logEvent("alias_search_disabled_an_alias", parameters: nil)
                }
                
            } else if let error = error {
                Toast.displayError(error)
                Analytics.logEvent("alias_search_toggle_error", parameters: error.toParameter())
            }
            
            self.tableView.reloadData()
        }
    }
    
    private func presentAlertConfirmDelete(alias: Alias, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete \(alias.email)", message: "🛑 People/apps who used to contact you via this alias cannot reach you any more. This operation is irreversible", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] (_) in
            self.delete(alias: alias, at: indexPath)
        }
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func delete(alias: Alias, at indexPath: IndexPath) {
        guard let apiKey = SLKeychainService.getApiKey() else {
            Toast.displayErrorRetrieveingApiKey()
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        SLApiService.deleteAlias(apiKey: apiKey, id: alias.id) { [weak self] (error) in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let error = error {
                Toast.displayError(error)
                Analytics.logEvent("alias_search_delete_error", parameters: error.toParameter())
            } else {
                self.tableView.performBatchUpdates({
                    self.aliases.removeAll(where: {$0 == alias})
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }) { (_) in
                    self.tableView.reloadData()
                    self.noAlias = self.aliases.count == 0
                    self.deletedAlias?(alias)
                    Toast.displayShortly(message: "Deleted alias \"\(alias.email)\"")
                }
                Analytics.logEvent("alias_search_delete_success", parameters: nil)
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
}

// MARK: - UITableViewDataSource
extension AliasSearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aliases.count
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
            Analytics.logEvent("alias_search_copy", parameters: nil)
        }
        
        cell.didTapSendButton = { [unowned self] in
            self.performSegue(withIdentifier: "showContacts", sender: alias)
            Analytics.logEvent("alias_search_view_contacts", parameters: nil)
        }
        
        cell.didTapDeleteButton = { [unowned self] in
            self.presentAlertConfirmDelete(alias: alias, at: indexPath)
        }
        
        cell.didTapRightArrowButton = { [unowned self] in
            self.performSegue(withIdentifier: "showActivities", sender: alias)
            Analytics.logEvent("alias_search_view_activities", parameters: nil)
        }
        
        return cell
    }
}
