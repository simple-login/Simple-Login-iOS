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
import FirebaseAnalytics

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
        Analytics.logEvent("open_alias_view_controller", parameters: nil)
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
            aliasActivityViewController.didUpdateNote = { [unowned self] in
                self.tableView.reloadData()
            }
            
        case let createAliasViewController as CreateAliasViewController:
            createAliasViewController.createdAlias = { [unowned self] alias in
                Toast.displayShortly(message: "Created \(alias)")
                self.refreshControl.beginRefreshing()
                self.refresh()
            }
            
        case let aliasSearchNavigationController as AliasSearchNavigationController:
            guard let aliasSearchViewController = aliasSearchNavigationController.viewControllers[0] as? AliasSearchViewController else { return }
            
            aliasSearchViewController.toggledAlias = { [unowned self] alias in
                for eachAlias in self.aliases {
                    if eachAlias == alias {
                        eachAlias.setEnabled(alias.enabled)
                        self.refilterAliasArrays()
                        self.tableView.reloadData()
                        break
                    }
                }
            }
            
            aliasSearchViewController.deletedAlias = { [unowned self] alias in
                self.aliases.removeAll(where: {$0 == alias})
                self.refilterAliasArrays()
                self.tableView.reloadData()
            }
            
        default: return
        }
    }
    
    @objc private func refresh() {
        fetchAliases()
        Analytics.logEvent("alias_list_refresh", parameters: nil)
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
                Analytics.logEvent("alias_list_fetch_error", parameters: error.toParameter())
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
                
                if enabled {
                    Analytics.logEvent("alias_list_enabled_an_alias", parameters: nil)
                } else {
                    Analytics.logEvent("alias_list_disabled_an_alias", parameters: nil)
                }
                
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
                Analytics.logEvent("alias_list_toggle_error", parameters: error.toParameter())
            }
        }
    }
}

// MARK: - Delete
extension AliasViewController {
    private func presentAlertConfirmDelete(alias: Alias, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete \"\(alias.email)\"?", message: "🛑 People/apps who used to contact you via this alias cannot reach you any more. This operation is irreversible. Please confirm.", preferredStyle: .alert)
        
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
                Analytics.logEvent("alias_list_delete_error", parameters: nil)
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
                
                Analytics.logEvent("alias_list_delete_success", parameters: nil)
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
        Analytics.logEvent("alias_list_change_filter_mode", parameters: nil)
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
                switch mode {
                case .uuid:
                    Analytics.logEvent("alias_random_by_uuid_error", parameters: nil)
                case .word:
                    Analytics.logEvent("alias_random_by_word_error", parameters: nil)
                }
                
            } else if let newlyCreatedAlias = newlyCreatedAlias {
                Toast.displayShortly(message: "Created \(newlyCreatedAlias)")
                self.refreshControl.beginRefreshing()
                self.refresh()
                
                switch mode {
                case .uuid:
                    Analytics.logEvent("alias_random_by_uuid_success", parameters: nil)
                case .word:
                    Analytics.logEvent("alias_random_by_word_success", parameters: nil)
                }
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
        
        performSegue(withIdentifier: "showActivities", sender: alias)
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
            Analytics.logEvent("alias_list_fetch_more", parameters: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let alias: Alias
        switch currentAliasType {
        case .all: alias = aliases[indexPath.row]
        case .active: alias = activeAliases[indexPath.row]
        case .inactive: alias = inactiveAliases[indexPath.row]
        }
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] (_, indexPath) in
            self.presentAlertConfirmDelete(alias: alias, at: indexPath)
        }
        
        return [deleteAction]
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
            Analytics.logEvent("alias_list_copy", parameters: nil)
        }
        
        cell.didTapSendButton = { [unowned self] in
            self.performSegue(withIdentifier: "showContacts", sender: alias)
            Analytics.logEvent("alias_list_view_contacts", parameters: nil)
        }
        
        cell.didTapRightArrowButton = { [unowned self] in
            self.performSegue(withIdentifier: "showActivities", sender: alias)
            Analytics.logEvent("alias_list_view_activities", parameters: nil)
        }
        
        return cell
    }
}

