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
        searchBar.showsCancelButton = true
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
    
    private func search(_ term: String) {
        guard let apiKey = SLKeychainService.getApiKey() else {
            Toast.displayErrorRetrieveingApiKey()
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        SLApiService.search(apiKey: apiKey, searchTerm: term) { [weak self] (aliases, error) in
            guard let self = self else { return }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let error = error {
                Toast.displayError(error)
            } else if let aliases = aliases {
                if aliases.count == 0 {
                    self.messageLabel.text = "No result for \"\(term)\""
                }
                
                self.aliases.removeAll()
                self.aliases.append(contentsOf: aliases)
                self.tableView.isHidden = aliases.count == 0
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension AliasSearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchTerm = searchBar.text {
            search(searchTerm)
        }
    }
}

// MARK: - UITableViewDelegate
extension AliasSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        cell.bind(with: aliases[indexPath.row])
        return cell
    }
}
