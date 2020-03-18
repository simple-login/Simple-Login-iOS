//
//  AliasViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD

final class AliasViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    private let refreshControl = UIRefreshControl()
    
    private enum AliasType {
        case all, active, inactive
    }
    
    private var aliases: [Alias] = []
    
    private var activeAliases: [Alias] = []
    private var inactiveAliases: [Alias] = []
    
    private var fetchedPage: Int = -1
    private var isFetching: Bool = false
    private var moreToLoad: Bool = true
    
    private var currentAliasType: AliasType = .all {
        didSet {
            tableView.reloadData()
            
            var scrollToTop: Bool = false
            switch currentAliasType {
            case .all: scrollToTop = aliases.count > 0
            case .active: scrollToTop = activeAliases.count > 0
            case .inactive: scrollToTop = inactiveAliases.count > 0
            }
            
            if scrollToTop {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    private var noAlias: Bool = false {
        didSet {
            tableView.isHidden = noAlias
        }
    }
    
    deinit {
        print("AliasViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        fetchAliases()
    }
    
    private func setUpUI() {
        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        
        AliasTableViewCell.register(with: tableView)
        tableView.register(UINib(nibName: "LoadingFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LoadingFooterView")
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            
        case let sendEmailViewController as ContactViewController:
            guard let alias = sender as? Alias else { return }
            sendEmailViewController.alias = alias
            
        case let aliasActivityViewController as AliasActivityViewController:
            guard let alias = sender as? Alias else { return }
            aliasActivityViewController.alias = alias
            
        case let createAliasViewController as CreateAliasViewController:
            createAliasViewController.createdAlias = { [unowned self] alias in
                Toast.displayShortly(message: "Created \(alias)")
                self.refreshControl.beginRefreshing()
                self.refresh()
            }
            
        default: return
        }
    }
    
    @objc private func refresh() {
        fetchAliases()
    }
    
    private func fetchAliases() {
        guard let apiKey = SLKeychainService.getApiKey() else {
            Toast.displayErrorRetrieveingApiKey()
            return
        }
        
        if refreshControl.isRefreshing {
            moreToLoad = true
        }
        
        guard moreToLoad, !isFetching else { return }
        
        isFetching = true
        
        let pageToFetch = refreshControl.isRefreshing ? 0 : fetchedPage + 1
        
        SLApiService.fetchAliases(apiKey: apiKey, page: pageToFetch) { [weak self] (aliases, error) in
            guard let self = self else { return }
            
            self.isFetching = false
            
            if let aliases = aliases {
                
                if aliases.count == 0 {
                    self.moreToLoad = false
                } else {
                    if self.refreshControl.isRefreshing {
                        print("Refreshed & fetched \(aliases.count) aliases")
                    } else {
                        print("Fetched page \(self.fetchedPage + 1) - \(aliases.count) aliases")
                    }
                    
                    if self.refreshControl.isRefreshing {
                        self.fetchedPage = 0
                        self.aliases.removeAll()
                    } else {
                        self.fetchedPage += 1
                    }
                    
                    self.aliases.append(contentsOf: aliases)
                    self.refilterAliasArrays()
                }
                
                self.noAlias = self.aliases.count == 0
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                
            } else if let error = error {
                self.refreshControl.endRefreshing()
                Toast.displayError(error)
            }
        }
    }
}

// MARK: - Toggle status
extension AliasViewController {
    private func toggle(alias: Alias, at indexPath: IndexPath) {
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
                
                self.tableView.performBatchUpdates({
                    switch self.currentAliasType {
                    case .all: return
                        
                    case .active:
                        self.activeAliases.removeAll(where: {$0 == alias})
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        
                    case .inactive:
                        self.inactiveAliases.removeAll(where: {$0 == alias})
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }) { (_) in
                    self.refilterAliasArrays()
                    self.tableView.reloadData()
                }
                
            } else if let error = error {
                Toast.displayError(error)
                // reload data to switch alias to initial state when request to server fails
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - Delete
extension AliasViewController {
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
            } else {
                self.tableView.performBatchUpdates({
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    switch self.currentAliasType {
                    case .all:
                        self.aliases.removeAll(where: {$0 == alias})
                        self.refilterAliasArrays()
                        
                    case .active:
                        self.activeAliases.removeAll(where: {$0 == alias})
                        self.aliases.removeAll(where: {$0 == alias})
                        
                    case .inactive:
                        self.inactiveAliases.removeAll(where: {$0 == alias})
                        self.aliases.removeAll(where: {$0 == alias})
                    }
                    
                }) { (_) in
                    self.tableView.reloadData()
                    self.noAlias = self.aliases.count == 0
                    Toast.displayShortly(message: "Deleted alias \"\(alias.email)\"")
                }
            }
        }
    }
}

// MARK: - SegmentedControl actions
extension AliasViewController {
    @IBAction private func segmentedControlValueChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: currentAliasType = .all
        case 1: currentAliasType = .active
        case 2: currentAliasType = .inactive
        default: return
        }
    }
    
    private func refilterAliasArrays() {
        activeAliases.removeAll()
        activeAliases.append(contentsOf: aliases.filter({$0.enabled == true}))
        
        inactiveAliases.removeAll()
        inactiveAliases.append(contentsOf: aliases.filter({$0.enabled == false}))
    }
}

// MARK: - Button actions
extension AliasViewController {
    @IBAction private func shuffleButtonTapped() {
        let alert = UIAlertController(title: "New email alias", message: "Randomly create an alias", preferredStyle: .actionSheet)
        
        let byWordAction = UIAlertAction(title: "By random words", style: .default) { [unowned self] (_) in
            self.showAddNoteAlert(mode: .word)
        }
        alert.addAction(byWordAction)
        
        let byUUIDAction = UIAlertAction(title: "By UUID", style: .default) { [unowned self] (_) in
            self.showAddNoteAlert(mode: .uuid)
        }
        alert.addAction(byUUIDAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showAddNoteAlert(mode: RandomMode) {
        let alert = UIAlertController(title: "Add some note for this alias", message: "This is optional and can be modified at anytime later.", preferredStyle: .alert)
        
        let noteTextView = alert.addTextView()
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [unowned self] _ in
            self.randomAlias(mode: mode, note: noteTextView.text)
        }
        alert.addAction(createAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true) {
            noteTextView.becomeFirstResponder()
        }
    }
    
    private func randomAlias(mode: RandomMode, note: String?) {
        guard let apiKey = SLKeychainService.getApiKey() else {
            Toast.displayErrorRetrieveingApiKey()
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        SLApiService.randomAlias(apiKey: apiKey, randomMode: mode, note: note) { [weak self] (newlyCreatedAlias, error) in
            guard let self = self else { return }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let error = error {
                Toast.displayError(error)
            } else if let newlyCreatedAlias = newlyCreatedAlias {
                Toast.displayShortly(message: "Created \(newlyCreatedAlias)")
                self.refreshControl.beginRefreshing()
                self.refresh()
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension AliasViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alias: Alias
        switch currentAliasType {
        case .all: alias = aliases[indexPath.row]
        case .active: alias = activeAliases[indexPath.row]
        case .inactive: alias = inactiveAliases[indexPath.row]
        }
        
        performSegue(withIdentifier: "showAliasActivity", sender: alias)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return moreToLoad ? 44.0 : 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if moreToLoad {
            let loadingFooterView =  tableView.dequeueReusableHeaderFooterView(withIdentifier: "LoadingFooterView") as? LoadingFooterView
            loadingFooterView?.animate()
            return loadingFooterView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if moreToLoad {
            fetchAliases()
        }
    }
}

// MARK: - UITableViewDataSource
extension AliasViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentAliasType {
        case .all: return aliases.count
        case .active: return activeAliases.count
        case .inactive: return inactiveAliases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AliasTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        
        let alias: Alias
        switch currentAliasType {
        case .all: alias = aliases[indexPath.row]
        case .active: alias = activeAliases[indexPath.row]
        case .inactive: alias = inactiveAliases[indexPath.row]
        }
        
        cell.bind(with: alias)
        
        cell.didToggleStatus = { [unowned self] isEnabled in
            self.toggle(alias: alias, at: indexPath)
        }
        
        cell.didTapCopyButton = {
            UIPasteboard.general.string = alias.email
            Toast.displayShortly(message: "Copied \"\(alias.email)\"")
        }
        
        cell.didTapSendButton = { [unowned self] in
            self.performSegue(withIdentifier: "showSendEmail", sender: alias)
        }
        
        cell.didTapDeleteButton = { [unowned self] in
            self.presentAlertConfirmDelete(alias: alias, at: indexPath)
        }
        
        cell.didTapRightArrowButton = { [unowned self] in
            self.performSegue(withIdentifier: "showAliasActivity", sender: alias)
        }
        
        return cell
    }
}

