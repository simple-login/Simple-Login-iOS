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
    
    deinit {
        print("AliasSearchViewController is deallocated")
    }
    
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
        guard let apiKey = SLKeychainService.getApiKey() else {
            Toast.displayErrorRetrieveingApiKey()
            return
        }
        
        if let term = term {
            self.searchTerm = term
            moreToLoad = true
            isFetching = false
            fetchedPage = -1
            aliases.removeAll()
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
                
                if (self.aliases.count == 0) {
                    self.noAlias = true
                    self.messageLabel.text = "No result found for \"\(self.searchTerm ?? "")\""
                } else {
                    self.noAlias = false
                }
                
                self.tableView.reloadData()
                
            } else if let error = error {
                Toast.displayError(error)
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
            //self.toggle(alias: alias, at: indexPath)
        }
        
        cell.didTapCopyButton = {
            UIPasteboard.general.string = alias.email
            Toast.displayShortly(message: "Copied \"\(alias.email)\"")
        }
        
        cell.didTapSendButton = { [unowned self] in
            self.performSegue(withIdentifier: "showContacts", sender: alias)
        }
        
        cell.didTapDeleteButton = { [unowned self] in
            //self.presentAlertConfirmDelete(alias: alias, at: indexPath)
        }
        
        cell.didTapRightArrowButton = { [unowned self] in
            self.performSegue(withIdentifier: "showActivities", sender: alias)
        }
        
        return cell
    }
}
